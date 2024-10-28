{
  description = "Polygon Full Node";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # Supported architectures: x86_64 and aarch64
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Import Nixpkgs for all systems
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      # Define the packages for all systems
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in {
          bor = import ./pkgs/bor/default.nix {
            lib = pkgs.lib;
            stdenv = pkgs.stdenv;
            buildGoModule = pkgs.buildGoModule;
            fetchFromGitHub = pkgs.fetchFromGitHub;
            libobjc = pkgs.darwin.libobjc;
            IOKit = pkgs.darwin.IOKit;
          };

          heimdall-polygon = import ./pkgs/heimdall-polygon/default.nix {
            lib = pkgs.lib;
            stdenv = pkgs.stdenv;
            buildGoModule = pkgs.buildGoModule;
            fetchFromGitHub = pkgs.fetchFromGitHub;
            libobjc = pkgs.darwin.libobjc;
            IOKit = pkgs.darwin.IOKit;
          };
        }
      );

      # Define devShell for development environments
      devShell = forAllSystems (system: 
        nixpkgsFor.${system}.mkShell {
          nativeBuildInputs = [
            self.packages.${system}.bor
            self.packages.${system}.heimdall-polygon
            nixpkgsFor.${system}.go
            nixpkgsFor.${system}.git
          ];
        }
      );

      # NixOS modules output
      nixosModules.bor = import ./modules/bor/default.nix;
      nixosModules.heimdall-polygon = import ./modules/heimdall-polygon/default.nix;
    };
}