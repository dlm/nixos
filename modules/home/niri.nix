{ lib, config, ... }:
{
  options.home.niri.enable = lib.mkEnableOption "niri compositor config";

  config = lib.mkIf config.home.niri.enable {
    xdg.configFile."niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/niri/config.kdl";
  };
}
