{ lib, config, ... }:
{
  options.home.fuzzel.enable = lib.mkEnableOption "fuzzel launcher";

  config = lib.mkIf config.home.fuzzel.enable {
    programs.fuzzel.enable = true;
    xdg.configFile."fuzzel/fuzzel.ini".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/fuzzel/fuzzel.ini";
  };
}
