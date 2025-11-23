{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.nushell.enable = lib.mkEnableOption "enables nushell";
  };

  config = lib.mkIf config.home.nushell.enable {
    # setup direnv
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    home.packages = with pkgs; [
      nushell

      # dependencies in the configuration
      atuin # for shell history
      zoxide # for moving around quickly
      starship # for fancy shell prompt
      carapace # for shell completion
    ];
  };
}
