lib:
with lib; {
  port = mkOption {
    type = types.port;
    default = 30303;
    description = "Port number Polygon Bor will be listening on, both TCP and UDP.";
  };

  http = {
    enable = mkEnableOption "Polygon Bor HTTP API";

    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "HTTP-RPC server listening interface";
    };

    port = mkOption {
      type = types.port;
      default = 8545;
      description = "Port number of Polygon Bor HTTP API.";
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "API's offered over the HTTP-RPC interface";
      example = ["net" "eth"];
    };

    corsdomain = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "List of domains from which to accept cross origin requests";
      example = ["*"];
    };

    rpcprefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "HTTP path path prefix on which JSON-RPC is served. Use '/' to serve on all paths.";
      example = "/";
    };

    vhosts = mkOption {
      type = types.listOf types.str;
      default = ["localhost"];
      description = ''
        Comma separated list of virtual hostnames from which to accept requests (server enforced).
        Accepts '*' wildcard.
      '';
      example = ["localhost" "polygon.example.org"];
    };
  };

  ws = {
    enable = mkEnableOption "Polygon Bor WebSocket API";
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen address of Polygon Bor WebSocket API.";
    };

    port = mkOption {
      type = types.port;
      default = 8546;
      description = "Port number of Polygon Bor WebSocket API.";
    };

    api = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = "APIs to enable over WebSocket";
      example = ["net" "eth"];
    };
  };

  authrpc = {
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen address of Polygon Bor Auth RPC API.";
    };

    port = mkOption {
      type = types.port;
      default = 8551;
      description = "Port number of Polygon Bor Auth RPC API.";
    };

    vhosts = mkOption {
      type = types.listOf types.str;
      default = ["localhost"];
      description = "List of virtual hostnames from which to accept requests.";
      example = ["localhost" "polygon.example.org"];
    };

    jwtsecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to a JWT secret for authenticated RPC endpoint.";
      example = "/var/run/bor/jwtsecret";
    };
  };

  metrics = {
    enable = mkEnableOption "Polygon Bor prometheus metrics";
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen address of Polygon Bor metrics service.";
    };

    port = mkOption {
      type = types.port;
      default = 6060;
      description = "Port number of Polygon Bor metrics service.";
    };
  };

  network = mkOption {
    type = types.nullOr (types.enum ["amoy"]);
    default = null;
    description = "The network to connect to. Mainnet (null) is the default Polygon network.";
  };

  networkid = mkOption {
    type = types.int;
    default = 1;
    description = "The network id used for peer to peer communication";
  };

  netrestrict = mkOption {
    # todo use regex matching
    type = types.nullOr types.str;
    default = null;
    description = "Restrict network communication to the given IP networks (CIDR masks)";
  };

  verbosity = mkOption {
    type = types.ints.between 0 5;
    default = 3;
    description = "log verbosity (0-5)";
  };

  nodiscover = mkOption {
    type = types.bool;
    default = false;
    description = "Disable discovery";
  };

  bootnodes = mkOption {
    # todo use regex matching
    type = types.nullOr (types.listOf types.str);
    default = null;
    description = "List of bootnodes to connect to";
  };

  syncmode = mkOption {
    type = types.enum ["snap" "fast" "full" "light"];
    default = "snap";
    description = "Blockchain sync mode.";
  };

  gcmode = mkOption {
    type = types.enum ["full" "archive"];
    default = "full";
    description = "Blockchain garbage collection mode.";
  };

  maxpeers = mkOption {
    type = types.int;
    default = 50;
    description = "Maximum peers to connect to.";
  };

  datadir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Data directory for Bor. Defaults to '%S/bor-\<name\>', which generally resolves to /var/lib/bor-\<name\>.";
  };
}