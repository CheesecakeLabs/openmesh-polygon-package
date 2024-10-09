let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
{
  polygon-heimdall = pkgs.callPackage ./polygon-heimdall.nix { inherit (pkgs.darwin) IOKit libobjc; };
}