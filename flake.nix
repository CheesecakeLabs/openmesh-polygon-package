{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }:
    {
      # Supported architectures: x86_64 and aarch64
      packages =
        let
          systems = [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
          ];
          forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

          # Load packages for each system
          polygonPackages = forAllSystems (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            import ./pkgs/default.nix
              {
                inherit self nixpkgs;
                lib = pkgs.lib;
              }
              .perSystem
              {
                self' = self;
                pkgs = pkgs;
                inherit system;
              }
          );
        in
        polygonPackages;

      # NixOS modules output
      nixosModules = import ./modules/default.nix;
    };
}