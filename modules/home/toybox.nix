{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.toybox.enable = lib.mkEnableOption "enables toybox";
  };

  config = lib.mkIf config.home.toybox.enable {
    home.packages = with pkgs; [
      bat
      glow
      tree
      yazi
    ];
  };
}
