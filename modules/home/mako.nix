{ lib, config, ... }:
{
  options.home.mako.enable = lib.mkEnableOption "mako notification daemon";

  config = lib.mkIf config.home.mako.enable {
    services.mako.enable = true;
    xdg.configFile."mako/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/mako/config";
  };
}
