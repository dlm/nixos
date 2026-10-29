{ lib, config, ... }:
{
  options.home.i3.enable = lib.mkEnableOption "i3 window manager config";

  config = lib.mkIf config.home.i3.enable {
    xdg.configFile."i3".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/i3";
  };
}
