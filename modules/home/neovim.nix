{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.neovim.enable = lib.mkEnableOption "enables neovim";
  };

  config = lib.mkIf config.home.neovim.enable {
    home.packages = with pkgs; [
      neovim

      # dependencies in the configuration
      ripgrep # telescope
      git # fugitive
    ];
  };
}
