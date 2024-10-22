{
  lib,
  pkgs,
  ...
}: let
  args = import ./args.nix lib;

  borOpts = with lib; {
    options = rec {
      enable = mkEnableOption "Bor polygon node";

      inherit args;

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments to pass to Bor node.";
        default = [];
      };

      package = mkOption {
        type = types.package;
        default = pkgs.bor;
        defaultText = literalExpression "pkgs.bor";
        description = "Package to use as Bor polygon node.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for any enabled networking services";
      };
    };
  };
in {
  options.services.polygon-bor = with lib;
    mkOption {
      type = types.attrsOf (types.submodule borOpts);
      default = {};
      description = "Specification of one or more bor instances.";
    };
}