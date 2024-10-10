with import <nixpkgs> {};

let
  eachHeimdall = config.services.heimdall;

  heimdallOpts = { config, lib, name, ...}: {

    options = {

      enable = lib.mkEnableOption "Heimdall Node (Polygon)";

      # Heimdall specific options
      chainId = mkOption {
        type = types.int;
        default = 137;
        description = "Chain ID of the Polygon network (137 for mainnet, 80001 for mumbai testnet).";
      };

      config = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the TOML configuration file for Heimdall.";
      };

      datadir = mkOption {
        type = types.str;
        default = "/var/lib/heimdall";
        description = "Path of the data directory to store information.";
      };

      dbBackend = mkOption {
        type = types.enum [ "leveldb" "pebble" ];
        default = "leveldb";
        description = "Database backend used by Heimdall.";
      };

      rpcAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Listen address for Heimdall RPC API.";
      };

      rpcPort = mkOption {
        type = types.port;
        default = 1317;
        description = "Port for Heimdall RPC API.";
      };

      grpcAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address for Heimdall gRPC API.";
      };

      grpcPort = mkOption {
        type = types.port;
        default = 9090;
        description = "Port for Heimdall gRPC API.";
      };

      validator = mkOption {
        type = types.str;
        default = "";
        description = "Public address of the validator on the Polygon network.";
      };

      keystore = mkOption {
        type = types.str;
        default = "/var/lib/heimdall/keystore";
        description = "Path to the keystore directory containing the validator key.";
      };

      seeds = mkOption {
        type = types.str;
        default = "seed1.polygon.io:26656,seed2.polygon.io:26656";
        description = "Seed nodes for connecting Heimdall to the Polygon network.";
      };

      pprof = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the pprof HTTP server.";
      };

      pprofAddr = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "pprof HTTP server listening interface.";
      };

      pprofPort = mkOption {
        type = types.port;
        default = 6060;
        description = "pprof HTTP server listening port.";
      };

      maxOpenConnections = mkOption {
        type = types.int;
        default = 100;
        description = "Maximum number of simultaneous RPC connections.";
      };

      logLevel = mkOption {
        type = types.enum [ "trace" "debug" "info" "warn" "error" "crit" ];
        default = "info";
        description = "Log level for Heimdall.";
      };

      verbosity = mkOption {
        type = types.int;
        default = 3;
        description = "Logging verbosity for Heimdall (5=trace|4=debug|3=info|2=warn|1=error|0=crit).";
      };

      snapshot = mkOption {
        type = types.bool;
        default = true;
        description = "Enables snapshot-database mode for fast sync.";
      };

      fastSync = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fast sync mode.";
      };

      txIndex = mkOption {
        type = types.bool;
        default = true;
        description = "Enable transaction indexing.";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments passed to Heimdall.";
      };

      package = mkPackageOption pkgs [ "heimdall" ] { };
    };
  };
in

{

  ###### interface

  options = {
    services.heimdall = mkOption {
      type = types.attrsOf (types.submodule heimdallOpts);
      default = {};
      description = "Specification of one or more Heimdall instances.";
    };
  };

  ###### implementation

  config = mkIf (eachHeimdall != {}) {

    environment.systemPackages = flatten (mapAttrsToList (heimdallName: cfg: [
      cfg.package
    ]) eachHeimdall);

    systemd.services = mapAttrs' (heimdallName: cfg: let
      stateDir = "heimdall/${heimdallName}";
      dataDir = "/var/lib/${stateDir}";
    in (
      nameValuePair "heimdall-${heimdallName}" (mkIf cfg.enable {
      description = "Heimdall node (Polygon) (${heimdallName})";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        StateDirectory = stateDir;

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";
      };

      script = ''
        ${cfg.package}/bin/heimdalld \
          --chain-id ${toString cfg.chainId} \
          ${optionalString (cfg.config != null) "--config ${cfg.config}"} \
          --datadir ${cfg.datadir} \
          --db-backend ${cfg.dbBackend} \
          --rpc.laddr tcp://${cfg.rpcAddress}:${toString cfg.rpcPort} \
          --grpc.address ${cfg.grpcAddress}:${toString cfg.grpcPort} \
          ${optionalString (cfg.validator != "") "--validator ${cfg.validator}"} \
          --keystore ${cfg.keystore} \
          --pprof.addr ${cfg.pprofAddr}:${toString cfg.pprofPort} \
          --max-open-connections ${toString cfg.maxOpenConnections} \
          --log-level ${cfg.logLevel} \
          --verbosity ${toString cfg.verbosity} \
          ${optionalString cfg.snapshot "--snapshot"} \
          ${optionalString cfg.fastSync "--fast-sync"} \
          ${optionalString cfg.txIndex "--tx-index"} \
          ${lib.escapeShellArgs cfg.extraArgs} \
          --datadir ${dataDir}
      '';
    }))) eachHeimdall;

  };

}