{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.stacks.desktop;

  # display manager session names for each session
  sessionNames = {
    i3 = "none+i3";
    niri = "niri";
  };
in
{
  # The base desktop (login screen, file manager, etc.) lives here; each
  # session that can be picked from the login screen is its own file.
  imports = [
    ./i3.nix
    ./niri.nix
  ];

  options.stacks.desktop = {
    enable = lib.mkEnableOption "desktop base shared by every session (login screen, file manager, ...)";

    defaultSession = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (builtins.attrNames sessionNames));
      default = null;
      description = ''
        Session preselected on the login screen. Must be one of the enabled
        sessions. null leaves it to the display manager, which remembers the
        last session used.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.i3.enable || cfg.niri.enable;
        message = "stacks.desktop is enabled without any session; enable stacks.desktop.i3 or stacks.desktop.niri.";
      }
      {
        assertion = cfg.defaultSession == null || cfg.${cfg.defaultSession}.enable;
        message = "stacks.desktop.defaultSession is \"${toString cfg.defaultSession}\" but stacks.desktop.${toString cfg.defaultSession} is not enabled.";
      }
    ];

    services.displayManager.defaultSession = lib.mkIf (
      cfg.defaultSession != null
    ) sessionNames.${cfg.defaultSession};

    # lightdm runs on X, even when the session it starts is Wayland
    services.xserver.enable = true;
    services.xserver.desktopManager.xterm.enable = false;

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

    home-manager.users.${username} =
      { config, ... }:
      {
        # wallpaper, read by feh (i3) and swaybg (niri)
        xdg.configFile."wallpaper".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/wallpaper";

        # auto-mount removable media
        services.udiskie.enable = true;

        home.packages = with pkgs; [
          # brightness control
          brightnessctl

          # network tray icon; starts itself via XDG autostart in any session
          # (shown in the i3bar and waybar trays)
          networkmanagerapplet

          # notify-send, used by scripts in either session (dunst or mako
          # displays it)
          libnotify
        ];
      };
  };
}
