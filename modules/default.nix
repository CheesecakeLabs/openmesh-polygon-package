{
  # Aggregate the Bor and Heimdall modules under a single 'default' export
  imports = [
    ./bor/default.nix
    ./heimdall/default.nix
  ];
}