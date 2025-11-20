{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    i3Desktop.enable = lib.mkEnableOption "enables i3";
  };

  config = lib.mkIf config.i3Desktop.enable {
    # xserver config
    services.xserver.enable = true;
    services.xserver.desktopManager.xterm.enable = false;

    # disk mounting
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    # file manager
    programs.thunar.enable = true;
    programs.xfconf.enable = true;

    services.xserver.windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        # status bar
        i3status
        networkmanagerapplet

        # person desktop environment
        i3lock # lock screen
        rofi # for the launcher
        feh # desktop background
        scrot # screen capture utility
        dunst # notification manager
        udiskie # auto-mount usb drives
        xcape # keyboard remapping
      ];
    };
  };
}
