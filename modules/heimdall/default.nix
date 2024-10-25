{ config, lib, pkgs, ... }:

let
  heimdallOpts = { config, lib, name, ... }: {
    options = {
      enable = lib.mkEnableOption "Polygon Heimdall Node";

      chain-id = lib.mkOption {
        type = lib.types.int;
        default = 137;
        description = "Chain ID of the Polygon network (e.g., 137 for mainnet, 80001 for Mumbai testnet).";
      };

      configFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the TOML configuration file for Heimdall.";
      };

      datadir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/heimdall";
        description = "Path to the Heimdall data directory.";
      };

      db-backend = lib.mkOption {
        type = lib.types.str;
        default = "leveldb";
        description = "Database backend used by Heimdall ('leveldb' or 'pebble').";
      };

      rpc-address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Listen address for Heimdall RPC API.";
      };

      rpc-port = lib.mkOption {
        type = lib.types.port;
        default = 1317;
        description = "Port for Heimdall RPC API.";
      };

      grpc-address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address for Heimdall gRPC API.";
      };

      grpc-port = lib.mkOption {
        type = lib.types.port;
        default = 9090;
        description = "Port for Heimdall gRPC API.";
      };

      validator = lib.mkOption {
        type = lib.types.str;
        description = "Public address of the validator on the Polygon network.";
      };

      keystore = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/heimdall/keystore";
        description = "Path to the keystore directory containing the validator key.";
      };

      seeds = lib.mkOption {
        type = lib.types.str;
        default = "seed1.polygon.io:26656,seed2.polygon.io:26656";
        description = "Seed nodes for connecting Heimdall to the Polygon network.";
      };

      log-level = lib.mkOption {
        type = lib.types.str;
        default = "info";
        description = "Log level for Heimdall (trace|debug|info|warn|error|crit).";
      };

      verbosity = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Logging verbosity for Heimdall (5=trace, 4=debug, 3=info, 2=warn, 1=error, 0=crit).";
      };

      snapshot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable snapshot-database mode for fast sync.";
      };

      tx-index = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable transaction indexing.";
      };

      fast-sync = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable fast sync mode.";
      };

      network = lib.mkOption {
        type = lib.types.str;
        default = "mainnet";
        description = "The network type (e.g., 'mainnet', 'mumbai').";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional arguments to pass to the Heimdall executable.";
      };
    };
  };
in
{
  options.services.heimdall = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule heimdallOpts);
    default = {};
    description = "Configuration for Polygon Heimdall nodes.";
  };

  config = lib.mkIf (config.services.heimdall != {}) {
    environment.systemPackages = lib.flatten (lib.mapAttrsToList (name: cfg: [
      pkgs.heimdall
    ]) config.services.heimdall);

    systemd.services = lib.mapAttrs' (name: cfg: let
      dataDir = cfg.datadir;
    in (
      lib.nameValuePair "heimdall-${name}" (lib.mkIf cfg.enable {
        description = "Polygon Heimdall Node (${name})";
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          ExecStart = ''
            ${pkgs.heimdall}/bin/heimdalld \
              --datadir ${dataDir} \
              --chain-id ${toString cfg.chain-id} \
              --rpc.address ${cfg.rpc-address} \
              --rpc.port ${toString cfg.rpc-port} \
              --grpc.address ${cfg.grpc-address} \
              --grpc.port ${toString cfg.grpc-port} \
              ${lib.optionalString (cfg.validator != null) "--validator ${cfg.validator}"} \
              --keystore ${cfg.keystore} \
              --seeds ${cfg.seeds} \
              --log-level ${cfg.log-level} \
              --verbosity ${toString cfg.verbosity} \
              ${lib.optionalString cfg.snapshot "--snapshot"} \
              ${lib.optionalString cfg.tx-index "--tx-index"} \
              ${lib.optionalString cfg.fast-sync "--fast-sync"} \
              ${lib.escapeShellArgs cfg.extraArgs}
          '';
          DynamicUser = true;
          Restart = "always";
          RestartSec = 5;
          StateDirectory = "heimdall";
          ProtectSystem = "full";
          PrivateTmp = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          MemoryDenyWriteExecute = true;
          StandardOutput = "journal";
          StandardError = "journal";
          User = "heimdall";
        };
      })
    )) config.services.heimdall;
  };
}