{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/configuration.nix
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  networking.hostName = "zbornak";

  # Enable firmware updates (recommended for Framework laptops)
  services.fwupd.enable = true;

  system.stateVersion = "25.11";
}
