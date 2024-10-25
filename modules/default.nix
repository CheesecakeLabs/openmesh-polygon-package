{
  # Aggregate the Bor and Heimdall modules under a single 'default' export
  default = {
    imports = [
      ./bor.nix
      ./heimdall.nix
    ];
  };
}