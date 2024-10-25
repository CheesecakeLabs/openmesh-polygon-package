{
  description = "Polygon Full Node";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: {
    # Load the packages from pkgs/default.nix
    packages.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      polygonPkgs = import ./pkgs/default.nix {
        inherit self nixpkgs;
        lib = pkgs.lib;
      };
    in polygonPkgs.perSystem { self' = self; system = "x86_64-linux"; pkgs = pkgs; };

    # NixOS modules output
    nixosModules = import ./modules/default.nix;
  };
}