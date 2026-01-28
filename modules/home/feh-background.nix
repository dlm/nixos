{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.services.feh-background = {
    enable = lib.mkEnableOption "feh service for setting background images";
    backgroundImage = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/feh/background";
      description = "Path to image to use as background";
    };
  };

  config = lib.mkIf config.services.feh-background.enable {
    home.packages = [ pkgs.feh ];

    systemd.user.services.feh-background = {
      Unit = {
        Description = "Set desktop background with feh";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${config.services.feh-background.backgroundImage}";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
