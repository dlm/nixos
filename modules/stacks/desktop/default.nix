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

    # file manager + virtual filesystem support
    services.gvfs.enable = true;
    programs.thunar.enable = true;
    programs.xfconf.enable = true;

    # Home Manager configuration
    home-manager.users.${username} = {
      # notificaiton manager
      services.dunst.enable = true;

      # background manager
      services.feh-background.enable = true;

      # clipboad manager
      services.clipmenu.enable = true;

      # auto-mount removable media
      services.udiskie.enable = true;

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
        libnotify # send notifications
        xcape # keyboard remapping
        xclip # clipboard management
        clipmenu # clipboard management
      ];
    };
  };
}
