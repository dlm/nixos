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
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
  ];

  networking.hostName = "zbornak";

  # Wayland only: X doesn't work well on this hardware
  stacks.desktop.niri.enable = true;
  stacks.desktop.defaultSession = "niri";
  stacks.desktop.niri.outputConfig = ''
    // 2880x1920 @ 13" laptop panel (~257 ppi)
    output "eDP-1" {
        mode "2880x1920@120.000"
        scale 2
    }

    // DELL U4025QW, 5120x2160 ultrawide (~140 ppi)
    output "DP-1" {
        mode "5120x2160@120.000"
        scale 1.25
    }
  '';

  # HiDPI display (2880x1920 @ 13") - 1.5x scaling for the lightdm greeter,
  # which still runs on X even though the session is Wayland.
  services.xserver.dpi = 144;

  home-manager.users.dave = {
    home.localConfig = {
      ghostty = "font-size = 12";
    };
  };

  # Enable firmware updates (recommended for Framework laptops)
  services.fwupd.enable = true;

  # backups
  stacks.backup = {
    enable = true;
    passwordSecret = "hosts/zbornak/restic-password";
    sshKeySecret = "hosts/zbornak/restic-ssh-key";
    paths = [
      "/home/dave/repos"
      "/home/dave/sync"
    ];
  };

  system.stateVersion = "25.11";
}
