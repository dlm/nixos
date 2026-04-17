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
    xresources.properties."Xft.dpi" = "144";
    home.file.".config/ghostty/config.local".text = ''
      font-size = 12
    '';
    home.file.".config/kitty/local.conf".text = ''
      font_size 12.0
    '';
  };

  # Enable firmware updates (recommended for Framework laptops)
  services.fwupd.enable = true;

  powerManagement.enable = true;
  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    HibernateDelaySec=2h
  '';

  services.logind.lidSwitch = "suspend-then-hibernate";

  boot.kernelParams = [ "resume=/dev/disk/by-uuid/5921c9da-4108-4349-a03b-6cb0bee86251" ];

  system.stateVersion = "25.11";
}
