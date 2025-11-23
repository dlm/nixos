{ config, pkgs, ... }:
{
  imports = [
    ../../modules/home
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dave";
  home.homeDirectory = "/home/dave";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.nushell.enable = true;
  home.neovim.enable = true;
  home.toybox.enable = true;
  home.git.enable = true;
  home.ai.enable = true;

  home.packages = with pkgs; [
    home-manager

    # standards
    fzf
    tmux

    # nice to haves
    gnumake

    # would like to move away from in favor of nushell
    jq
    httpie
  ];

  # Here we use mkOutofStoreSymlink so that we don't have to
  # rerun home manager on every config update
  home.file = {
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/zsh/zshrc.local;
    "bin/scripts/".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/bin/scripts;
    "bin/scripts-bky/".source =
      config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env-bky/bin/scripts;
  };

  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/nvim;
    "tmux".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/tmux;
    "i3".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/i3;
    "zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/zsh;
    "rofi".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/rofi;
    "git".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/git;
    "nushell/config.nu".source =
      config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/nushell/config.nu;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dave/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # use dropbox
  nixpkgs.config.allowUnfree = true;
  # services.dropbox.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
