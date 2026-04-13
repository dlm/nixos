{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.keyboard-remap.enable = lib.mkEnableOption "enables keyboard remapping";
  };

  config = lib.mkIf config.home.keyboard-remap.enable {
    systemd.user.services.xkb-remap = {
      Unit = {
        Description = "XKB keyboard remapping";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.xorg.setxkbmap}/bin/setxkbmap -option 'ctrl:nocaps'";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    services.xcape = {
      enable = true;
      mapExpression = {
        "Control_L" = "Escape";
      };
    };

    systemd.user.services.xcape.Unit.After = [ "xkb-remap.service" ];
  };
}
