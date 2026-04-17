{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/configuration.nix
  ];

  networking.hostName = "petrillo";

  home-manager.users.dave = {
    home.file.".config/ghostty/config.local".text = ''
      font-size = 10
    '';
    home.file.".config/kitty/local.conf".text = ''
      font_size 10.0
    '';
  };

  system.stateVersion = "24.11";
}
