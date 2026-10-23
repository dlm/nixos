{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:
let
  muxwm = inputs.muxwm.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  options.stacks.desktop = {
    enable = lib.mkEnableOption "desktop stack with i3 window manager";
  };

  config = lib.mkIf config.stacks.desktop.enable {
    # xserver config
    services.xserver.enable = true;
    services.xserver.desktopManager.xterm.enable = false;
    services.xserver.windowManager.i3.enable = true;
    services.xserver.autoRepeatDelay = 300;
    services.xserver.autoRepeatInterval = 20;

    # login screen: lightdm-slick-greeter instead of the default gtk greeter.
    # gtk-greeter's login box uses fixed pixel widths that don't flex for a
    # larger font (text got cut off at 16pt) -- slick-greeter's layout
    # actually scales.
    services.xserver.displayManager.lightdm.background = "#1d1f21";
    services.xserver.displayManager.lightdm.greeters.slick = {
      enable = true;
      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font.name = "Ubuntu 15";
      cursorTheme.size = 24;
    };

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
        xclip # clipboard management
        clipmenu # clipboard management

        # brightness control
        brightnessctl

        # personal tools
        muxwm
      ];
    };
  };
}
