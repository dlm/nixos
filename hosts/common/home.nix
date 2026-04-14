{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.key-safe.homeManagerModules.secrets
    ../../modules/home
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dave";
  home.homeDirectory = "/home/dave";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.nushell.enable = true;
  home.keyboard-remap.enable = true;
  home.neovim.enable = true;
  home.toybox.enable = true;
  home.git.enable = true;
  home.ai.enable = true;

  home.packages = with pkgs; [
    home-manager

    # key management
    sops

    # standards
    fzf
    tmux

    # nice to haves
    gnumake
    zathura
    taskwarrior3

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
    # our launch script acts as a wrapper for the various tools we use across
    # many projects.  We put that in a "well known" location so that we can
    # link the launch script to a "well known" location
    # so that we can launch our tool from anywhere
    ".local/bin/launch".source =
      config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/bin/scripts/launch;
  };

  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/nvim;
    "tmux".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/tmux;
    "i3".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/i3;
    "zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/zsh;
    "rofi".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/rofi;
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/ghostty;
    "git".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/git;
    "feh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/feh;
    "dunst/dunstrc".source = config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/dunst/dunstrc;
  };

  programs.nushell.extraConfig = ''
    source /home/dave/repos/dlm/env/nushell/config.nu
  '';

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

  nixpkgs.config.allowUnfree = true;

  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        petrillo.id = "ZD6ISOA-AVKTGWH-OHFRGEZ-6MZNIJT-6PBDXC3-J7M23WX-C6DUHQ6-E2HPPAS";
        zbornak.id = "ZFML5X7-W3ZPIDT-3YB3DPI-AY3JUBR-DRY533J-MHDEDGX-T7CZO3X-P7E7HQ3";
        tanner.id = "DH27P74-WUSNTGM-GGLXCZA-2PWMGES-SLJJ266-CIP2QBC-CMN5NFF-FTLHJQG";
      };
      folders = {
        notes = {
          path = "~/sync/notes";
          devices = [
            "zbornak"
            "petrillo"
            "tanner"
          ];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "31536000"; # 1 year
            };
          };
        };
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
