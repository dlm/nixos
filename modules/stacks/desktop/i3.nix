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
  options.stacks.desktop.i3 = {
    enable = lib.mkEnableOption "i3 session";
  };

  config = lib.mkIf config.stacks.desktop.i3.enable {
    # the login screen and shared desktop base
    stacks.desktop.enable = true;

    # xserver config
    services.xserver.windowManager.i3.enable = true;
    services.xserver.autoRepeatDelay = 300;
    services.xserver.autoRepeatInterval = 20;

    # Home Manager configuration
    home-manager.users.${username} = {
      home.i3.enable = true;
      home.rofi.enable = true;

      # notification manager
      home.dunst.enable = true;

      # background manager
      services.feh-background.enable = true;

      # clipboad manager
      services.clipmenu.enable = true;

      # Base packages for the i3 session
      home.packages = with pkgs; [
        # status bar
        i3status

        # person desktop environment
        i3lock # lock screen
        scrot # screen capture utility
        xclip # clipboard management
        clipmenu # clipboard management
        arandr

        # personal tools
        muxwm
      ];
    };
  };
}
