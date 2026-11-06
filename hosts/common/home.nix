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
  home.zsh.enable = true;
  home.neovim.enable = true;
  home.toybox.enable = true;
  home.git.enable = true;
  home.ai.enable = true;

  home.packages = with pkgs; [
    home-manager

    # key management
    sops

    # backup
    restic

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
    "bin/scripts/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/bin/scripts";
    # our launch script acts as a wrapper for the various tools we use across
    # many projects.  We put that in a "well known" location so that we can
    # link the launch script to a "well known" location
    # so that we can launch our tool from anywhere
    ".local/bin/launch".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/bin/scripts/launch";
  };

  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/nvim";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/tmux";
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/ghostty";
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/kitty";
    "git".source = config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/git";
    "direnv/direnv.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/direnv/direnv.toml";
    "direnv/direnvrc".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.envRepoPath}/direnv/direnvrc";
  };

  programs.nushell.extraConfig = ''
    source ${config.home.envRepoPath}/nushell/config.nu
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
  # Dark mode for GTK3/4 apps and libadwaita (also used by XDG portal for flatpak apps)
  # Catppuccin theme so GTK apps (nm-applet, blueman-manager, etc.) match the
  # frappe palette used in waybar/kitty/rofi/etc.
  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    theme = {
      name = "catppuccin-frappe-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        variant = "frappe";
      };
    };
    gtk4.theme = config.gtk.theme;
  };

  # services.blueman.enable (hosts/common/configuration.nix) autostarts
  # blueman-applet for its tray icon. We still want blueman-manager for
  # pairing, just not a tray icon dedicated to it -- this overrides the
  # system-wide autostart entry per the XDG autostart spec.
  xdg.configFile."autostart/blueman.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

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
        zbornak.id = "YPFPMEH-ZJTBKZ3-GJHUEJ2-HCYMQZB-UTV7ZTE-ZOTNSLI-IKHME53-6RBXWQH";
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
