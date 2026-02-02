# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:
let
  wavebox = import ../../packages/wavebox.nix { inherit pkgs; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    # ../../modules/system/kanata.nix
    ../../modules/stacks/desktop
  ];

  # Make username available to all modules
  _module.args = {
    username = "dave";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "petrillo"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [
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

  # # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

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
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "dave" = import ./home.nix;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install zsh
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.alsa-utils

    pkgs.keymapp

    pkgs.vim
    pkgs.google-chrome
    pkgs.distrobox
    pkgs.slack
    # pkgs.wavebox
    wavebox

    # TODO: tools needed for my neovim setup
    # these should probably be in my home config
    # since they support neovim
    pkgs.unzip
    pkgs.wget
    pkgs.fd
    pkgs.xclip
    pkgs.harper

    # these are some standard tooling that I use independent of projects
    # however I am not sure if they are here because of that or if they
    # are needed for neovim
    # TODO: figure that out and put then in a neovim module if they are needed
    # for neovim or put them in the nice to have sections if they are just
    # needed for nice to have
    # If they are needed for neovim, it would be helpful to add "why"
    pkgs.gcc
    pkgs.python3
    pkgs.stylua
    pkgs.lua-language-server
    pkgs.nixfmt-rfc-style
    pkgs.ghostty
    pkgs.arandr
  ];

  # setup flatpak
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*"; # use the first portal implementation that works
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
    "io.github.zen_browser.zen"
    "org.telegram.desktop"
    "com.discordapp.Discord"
    "org.signal.Signal"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # setup podman
  virtualisation.podman = {
    enable = true;
    # dockerCompat = true;
  };

  # or docker (less awesome, but I can't figure out how to
  # migrate blocky/archive to work with podman
  # virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  virtualisation.docker = {
    enable = true;
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
    daemon.settings = {
      dns = [
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };

  # users.dave.extraGroups = [ "docker" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  services.resolved.enable = true;
  # networking.resolvconf.useLocalResolver = true;

  # kanata.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
