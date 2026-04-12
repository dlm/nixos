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

  system.stateVersion = "24.11";
}
