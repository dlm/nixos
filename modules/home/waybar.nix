{ lib, config, ... }:
{
  options.home.waybar.enable = lib.mkEnableOption "waybar status bar";

  config = lib.mkIf config.home.waybar.enable {
    programs.waybar.enable = true;
    xdg.configFile."waybar/config.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/waybar/config.jsonc";
    xdg.configFile."waybar/style.css".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/waybar/style.css";
  };
}
