lib:
with lib; {
  port = mkOption {
    type = types.port;
    default = 26656;
    description = "Port number Heimdall will be listening on for peer-to-peer connections.";
  };

  rpc = {
    enable = mkEnableOption "Heimdall RPC API";

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "RPC server listening interface";
    };

    port = mkOption {
      type = types.port;
      default = 1317;
      description = "Port number of Heimdall RPC API.";
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "API's offered over the RPC interface";
      example = ["net" "heimdall"];
    };

    corsdomain = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "List of domains from which to accept cross-origin requests";
      example = ["*"];
    };
  };

  p2p = {
    enable = mkEnableOption "Heimdall peer-to-peer network";

    addr = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address for peer-to-peer networking.";
    };

    port = mkOption {
      type = types.port;
      default = 26656;
      description = "Port number of Heimdall peer-to-peer network.";
    };

    seeds = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "Comma-separated list of seed nodes for peer-to-peer networking.";
      example = ["seed1.example.com:26656" "seed2.example.com:26656"];
    };

    persistent_peers = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "Comma-separated list of persistent peers.";
      example = ["peer1.example.com:26656" "peer2.example.com:26656"];
    };
  };

  prometheus = {
    enable = mkEnableOption "Heimdall Prometheus metrics";

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address for Prometheus metrics.";
    };

    port = mkOption {
      type = types.port;
      default = 26660;
      description = "Port number for Prometheus metrics.";
    };
  };

  node_key = mkOption {
    type = types.str;
    default = "/var/lib/heimdall/config/node_key.json";
    description = "Path to the node private key file.";
  };

  priv_validator_key = mkOption {
    type = types.str;
    default = "/var/lib/heimdall/config/priv_validator_key.json";
    description = "Path to the validator private key file.";
  };

  priv_validator_state = mkOption {
    type = types.str;
    default = "/var/lib/heimdall/config/priv_validator_state.json";
    description = "Path to the validator state file.";
  };

  data_dir = mkOption {
    type = types.str;
    default = "/var/lib/heimdall/data";
    description = "Directory for Heimdall's blockchain data.";
  };

  log_level = mkOption {
    type = types.enum ["info" "debug" "error" "panic"];
    default = "info";
    description = "Logging level for Heimdall.";
  };

  log_format = mkOption {
    type = types.enum ["text" "json"];
    default = "text";
    description = "Format of logs, either plain text or JSON.";
  };

  max_open_connections = mkOption {
    type = types.int;
    default = 100;
    description = "Maximum number of open connections for Heimdall.";
  };

  max_peers = mkOption {
    type = types.int;
    default = 50;
    description = "Maximum number of peers Heimdall will connect to.";
  };

  timeout_commit = mkOption {
    type = types.int;
    default = 1000;
    description = "Timeout duration (in milliseconds) for committing a block.";
  };

  fast_sync = mkOption {
    type = types.bool;
    default = true;
    description = "Enable or disable fast synchronization.";
  };
}