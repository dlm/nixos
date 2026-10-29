{ lib, pkgs, config, ... }:
{
  options.home.rofi.enable = lib.mkEnableOption "rofi launcher";

  config = lib.mkIf config.home.rofi.enable {
    home.packages = [ pkgs.rofi ];
    xdg.configFile."rofi".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/rofi";
  };
}
