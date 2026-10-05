{
  config,
  pkgs,
  inputs,
  ...
}:
let
  wavebox = inputs.wavebox.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/stacks/desktop
    ../../modules/stacks/backup
    ../../modules/system/keyd.nix
  ];

  # Make username available to all modules
  _module.args = {
    username = "dave";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://cache.numtide.com" ];
    # Also listed as trusted so the flake's own nixConfig request is
    # accepted rather than warned about on every evaluation.
    trusted-substituters = [ "https://cache.numtide.com" ];
    trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable desktops
  services.displayManager.defaultSession = "none+i3";
  stacks.desktop.enable = true;

  # Enable keybord tools
  hardware.keyboard.zsa.enable = true;
  hardware.keyboard.laptop-remap.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth and make it so that it is setup on boot
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.dave = {
    isNormalUser = true;
    shell = pkgs.nushell;
    description = "David Millman";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLdx+x2TuJeHgGKc5SPiXlsIvlFcnzikcwaFCNOkLuu dave@zbornak"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeNhaORfgxVdjqqEX2/rR/4z6viQYVFrGidXx4N9F4V dave@petrillo"
    ];

  };

  # Enable removable media management
  services.udisks2.enable = true;

  # Polkit rules - allow wheel group to mount USB drives without password
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("wheel")
        && (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
            action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
            action.id == "org.freedesktop.udisks2.eject-media" ||
            action.id == "org.freedesktop.udisks2.power-off-drive")
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.departure-mono
    nerd-fonts.jetbrains-mono
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "dave" = import ../common/home.nix;
    };
  };

  # Enable dconf (needed for GTK settings/dark mode under non-GNOME sessions)
  programs.dconf.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Install zsh
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.alsa-utils

    pkgs.keymapp

    pkgs.vim
    pkgs.google-chrome
    pkgs.distrobox
    pkgs.slack

    wavebox

    pkgs.unzip
    pkgs.wget
    pkgs.fd
    pkgs.xclip
    pkgs.harper

    pkgs.gcc
    pkgs.python3
    pkgs.stylua
    pkgs.lua-language-server
    pkgs.nixfmt-rfc-style
    pkgs.ghostty
    pkgs.kitty
    pkgs.arandr
  ];

  # setup flatpak
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  services.flatpak.enable = true;
  services.flatpak.packages = [
    {
      appId = "com.brave.Browser";
      origin = "flathub";
    }
    "com.obsproject.Studio"
    "org.zulip.Zulip"
    "md.obsidian.Obsidian"
    "app.zen_browser.zen"
    "org.telegram.desktop"
    "com.discordapp.Discord"
    "org.signal.Signal"
  ];

  # setup podman
  virtualisation.podman = {
    enable = true;
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
    daemon.settings = {
      dns = [
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

  networking.firewall.enable = false;
  services.resolved.enable = true;

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "dave" ];
    };
  };
}
