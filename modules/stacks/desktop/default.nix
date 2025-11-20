{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.stacks.desktop = {
    enable = lib.mkEnableOption "desktop stack with i3 window manager";
  };

  config = lib.mkIf config.stacks.desktop.enable {
    # xserver config
    services.xserver.enable = true;
    services.xserver.desktopManager.xterm.enable = false;
    services.xserver.windowManager.i3.enable = true;

    # disk mounting
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    # file manager
    programs.thunar.enable = true;
    programs.xfconf.enable = true;

    # Home Manager configuration
    home-manager.users.${username} = {
      services.dunst.enable = true;

      # Base packages for desktop stack
      home.packages = with pkgs; [
        # status bar
        i3status
        networkmanagerapplet

        # person desktop environment
        i3lock # lock screen
        rofi # launcher
        feh # desktop background
        scrot # screen capture utility
        dunst # notification manager
        udiskie # auto-mount usb drives
        xcape # keyboard remapping
      ];
    };
  };
}
