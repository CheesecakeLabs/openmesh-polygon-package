{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesLib = import ../lib.nix lib;

  inherit (lib.lists) optionals findFirst;
  inherit (lib.strings) hasPrefix;
  inherit (lib.attrsets) zipAttrsWith;
  inherit
    (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs'
    mapAttrsToList
    mkIf
    mkMerge
    nameValuePair
    ;
  inherit (modulesLib) mkArgs baseServiceConfig;

  # capture config for all configured Heimdall nodes
  eachHeimdall = config.services.heimdall;
in {
  ###### interface
  inherit (import ./options.nix {inherit lib pkgs;}) options;

  ###### implementation

  config = mkIf (eachHeimdall != {}) {
    # configure the firewall for each service
    networking.firewall = let
      openFirewall = filterAttrs (_: cfg: cfg.openFirewall) eachHeimdall;
      perService =
        mapAttrsToList
        (
          _: cfg:
            with cfg.args; {
              allowedUDPPorts = [port];
              allowedTCPPorts =
                [port rpc.port]
                ++ (optionals prometheus.enable [prometheus.port])
                ++ (optionals p2p.enable [p2p.port]);
            }
        )
        openFirewall;
    in
      zipAttrsWith (_name: flatten) perService;

    # create a service for each instance
    systemd.services =
      mapAttrs'
      (
        heimdallName: let
          serviceName = "heimdall-${heimdallName}";
        in
          cfg: let
            scriptArgs = let
              # replace enable flags like --rpc.enable with just --rpc
              pathReducer = path: let
                arg = concatStringsSep "." (lib.lists.remove "enable" path);
              in "--${arg}";

              # generate flags
              args = let
                opts = import ./args.nix lib;
              in
                mkArgs {
                  inherit pathReducer opts;
                  inherit (cfg) args;
                };

              # filter out certain args which need to be treated differently
              specialArgs = ["--network" "--node_key" "--priv_validator_key"];
              isNormalArg = name: (findFirst (arg: hasPrefix arg name) null specialArgs) == null;

              filteredArgs = builtins.filter isNormalArg args;

              network =
                if cfg.args.network != null
                then "--network ${cfg.args.network}"
                else "";

              nodeKey =
                if cfg.args.node_key != null
                then "--node_key ${cfg.args.node_key}"
                else "";

              privValidatorKey =
                if cfg.args.priv_validator_key != null
                then "--priv_validator_key ${cfg.args.priv_validator_key}"
                else "";

              datadir =
                if cfg.args.data_dir != null
                then "--data_dir ${cfg.args.data_dir}"
                else "--data_dir %S/${serviceName}";
            in ''
              ${datadir} \
              ${network} ${nodeKey} ${privValidatorKey} \
              ${concatStringsSep " \\\n" filteredArgs} \
              ${lib.escapeShellArgs cfg.extraArgs}
            '';
          in
            nameValuePair serviceName (mkIf cfg.enable {
              after = ["network.target"];
              wantedBy = ["multi-user.target"];
              description = "Polygon Heimdall node (${heimdallName})";

              environment = {
                RPC_HTTP_HOST = cfg.args.rpc.addr;
                RPC_HTTP_PORT = builtins.toString cfg.args.rpc.port;
              };

              # create service config by merging with the base config
              serviceConfig = mkMerge [
                baseServiceConfig
                {
                  User = serviceName;
                  StateDirectory = serviceName;
                  ExecStart = "${cfg.package}/bin/heimdalld ${scriptArgs}";
                }
                (mkIf (cfg.args.node_key != null) {
                  LoadCredential = ["node_key:${cfg.args.node_key}"];
                })
              ];
            })
      )
      eachHeimdall;
  };
}