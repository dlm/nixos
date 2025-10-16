{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    toybox.enable = lib.mkEnableOption "enables toybox";
  };

  config = lib.mkIf config.toybox.enable {
    home.packages = [
      pkgs.bat
      pkgs.glow
    ];
  };
}
