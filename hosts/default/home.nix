{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dave";
  home.homeDirectory = "/home/dave";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.home-manager

    # while this block contains some nice to haves, I think that they
    # may be required by my neovim setup.
    # TODO: figure out if they are required by neovim or just that they are
    # things I always user.
    # if neovim required, add to neovim and document why
    pkgs.git # neovim plugin fugitive?
    pkgs.fzf # neovim plugin telescope?
    pkgs.ripgrep # neovim plugin telescope?

    pkgs.atuin
    pkgs.zoxide
    pkgs.starship
    pkgs.nushell
    pkgs.carapace

    pkgs.neovim
    pkgs.tmux

    # nice to haves
    pkgs.bat
    pkgs.gnumake
    pkgs.gh
    pkgs.jq
    pkgs.httpie
    pkgs.tree

    pkgs.gemini-cli

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/zsh/zshrc.local;
    "bin/scripts/".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/bin/scripts;
    "bin/scripts-bky/".source =
      config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env-bky/bin/scripts;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/nvim;
    "tmux".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/tmux;
    "i3".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/i3;
    "zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/zsh;
    "rofi".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/rofi;
    "git".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/git;
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
  services.dropbox.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # setup direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
