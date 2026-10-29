{ lib, config, ... }:
{
  options.home.dunst.enable = lib.mkEnableOption "dunst notification daemon";

  config = lib.mkIf config.home.dunst.enable {
    services.dunst.enable = true;
    xdg.configFile."dunst/dunstrc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/dunst/dunstrc";
  };
}
