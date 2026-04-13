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

  # HiDPI display (2880x1920 @ 13") - 1.5x scaling
  home-manager.users.dave = {
    xresources.properties = {
      "Xft.dpi" = "144";
    };
  };

  # Enable firmware updates (recommended for Framework laptops)
  services.fwupd.enable = true;

  system.stateVersion = "25.11";
}
