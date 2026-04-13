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

    programs.nushell.enable = true;
    programs.starship.enable = true;
    programs.atuin.enable = true;
    programs.zoxide.enable = true;
    programs.carapace.enable = true;
  };
}
