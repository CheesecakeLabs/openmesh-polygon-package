{
  description = "Polygon Full Node";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: 
  let
    # Define supported systems
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs for each system
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    # Define the per-system package logic
    perSystem = {
      self',
      pkgs,
      system,
      ...
    }: let
      inherit (pkgs) callPackage;
      inherit (nixpkgs.lib.extras.flakes) platformPkgs platformApps;
    in {
      packages = platformPkgs system rec {
        bor = callPackage ./pkgs/bor { inherit (pkgs.darwin) IOKit libobjc; };
        heimdall = callPackage ./pkgs/heimdall { inherit (pkgs.darwin) IOKit libobjc; };
      };

      apps = platformApps self'.packages {
        bor = { bin = "bor"; };
        heimdall = {
          bin = "heimdalld";
          heimdallcli.bin = "heimdallcli";
        };
      };
    };
  
  in {
    # Define the overlay to expose packages
    flake.overlays.default = _final: prev: let
      inherit (prev.stdenv.hostPlatform) system;
    in
      if builtins.hasAttr system self.packages
      then self.packages.${system}
      else {};

    # Expose packages for each system
    packages = forAllSystems (system:
      let pkgs = nixpkgsFor.${system};
      in perSystem { self' = self; pkgs = pkgs; inherit system; }
    );

    # Expose NixOS modules
    nixosModules = {
      bor = import ./modules/bor/default.nix;
      heimdall = import ./modules/heimdall/default.nix;
    };
  };
}