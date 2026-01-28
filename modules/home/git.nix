{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.git.enable = lib.mkEnableOption "enables git";
  };

  config = lib.mkIf config.home.git.enable {
    home.packages = with pkgs; [
      git

      delta # nice looking git diffing
      gh # convient github specifics
    ];
  };
}
