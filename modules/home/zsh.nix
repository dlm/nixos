{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.zsh.enable = lib.mkEnableOption "enables zsh";
  };

  # zsh itself (and /etc/zshrc) comes from programs.zsh in the system config.
  # The zshrc is plain config in the env repo rather than home-manager's
  # programs.zsh, so it also works on machines without nix.
  config = lib.mkIf config.home.zsh.enable {
    home.file.".zshrc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/zsh/zshrc.local";
    xdg.configFile."zsh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/zsh";

    # tools the zshrc initialises
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.starship.enable = true;
    programs.atuin.enable = true;
    programs.zoxide.enable = true;

    home.packages = with pkgs; [
      zplug # plugin manager, sourced from ~/.nix-profile/share/zplug
      fzf
      ripgrep # FZF_DEFAULT_COMMAND
    ];
  };
}
