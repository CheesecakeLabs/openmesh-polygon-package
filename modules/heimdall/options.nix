{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  heimdallOpts = with lib; {
    options = rec {
      enable = mkEnableOption "Heimdall Polygon node";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Heimdall node.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.heimdall;
        defaultText = literalExpression "pkgs.heimdall";
        description = "Package to use as Heimdall Polygon node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.polygon.heimdall = with lib;
    mkOption {
      type = types.attrsOf (types.submodule heimdallOpts);
      default = {};
      description = "Specification of one or more Heimdall instances.";
    };
}