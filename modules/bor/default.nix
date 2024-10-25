{ config, lib, pkgs, ... }:

let
  borOpts = { config, lib, name, ... }: {
    options = {
      enable = lib.mkEnableOption "Polygon Bor Node";

      chain = lib.mkOption {
        type = lib.types.str;
        default = "mainnet";
        description = "Name of the chain to sync ('amoy', 'mumbai', 'mainnet') or path to a genesis file.";
      };

      configFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the TOML configuration file.";
      };

      datadir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/bor";
        description = "Path of the data directory to store blockchain data.";
      };

      heimdall = lib.mkOption {
        type = lib.types.str;
        default = "http://localhost:1317";
        description = "URL of the Heimdall service.";
      };

      grpcAddr = lib.mkOption {
        type = lib.types.str;
        default = ":3131";
        description = "Address and port to bind the GRPC server.";
      };

      logs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enables Bor log retrieval.";
      };

      runheimdall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Run Heimdall service as a child process.";
      };

      syncmode = lib.mkOption {
        type = lib.types.str;
        default = "full";
        description = "Blockchain sync mode (only 'full' is supported by Bor).";
      };

      gcmode = lib.mkOption {
        type = lib.types.str;
        default = "full";
        description = "Blockchain garbage collection mode.";
      };

      verbosity = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Logging verbosity for the server (5=trace, 4=debug, 3=info, 2=warn, 1=error, 0=crit).";
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional arguments passed to the Bor executable.";
      };
    };
  };
in
{
  options.services.bor = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule borOpts);
    default = {};
    description = "Configuration for Polygon Bor nodes.";
  };

  config = lib.mkIf (config.services.bor != {}) {
    environment.systemPackages = lib.flatten (lib.mapAttrsToList (name: cfg: [
      pkgs.bor
    ]) config.services.bor);

    systemd.services = lib.mapAttrs' (name: cfg: let
      dataDir = cfg.datadir;
    in (
      lib.nameValuePair "bor-${name}" (lib.mkIf cfg.enable {
        description = "Polygon Bor Node (${name})";
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          ExecStart = ''
            ${pkgs.bor}/bin/bor \
              --datadir ${dataDir} \
              --chain ${cfg.chain} \
              --verbosity ${toString cfg.verbosity} \
              --syncmode ${cfg.syncmode} \
              --gcmode ${cfg.gcmode} \
              --heimdall ${cfg.heimdall} \
              --grpc ${cfg.grpcAddr} \
              ${lib.optionalString cfg.logs "--log"} \
              ${lib.escapeShellArgs cfg.extraArgs}
          '';
          DynamicUser = true;
          Restart = "always";
          RestartSec = 5;
          StateDirectory = "bor";
          ProtectSystem = "full";
          PrivateTmp = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          MemoryDenyWriteExecute = true;
          StandardOutput = "journal";
          StandardError = "journal";
          User = "bor";
        };
      })
    )) config.services.bor;
  };
}