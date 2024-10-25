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
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          bor = import ./pkgs/bor/default.nix { inherit self nixpkgs pkgs; lib = pkgs.lib; };
          heimdall = import ./pkgs/heimdall/default.nix { inherit self nixpkgs pkgs; lib = pkgs.lib; };
        }
      );

      # NixOS modules output
      nixosModules.bor = import ./modules/bor/default.nix;
    };
}