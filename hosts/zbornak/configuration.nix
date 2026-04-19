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
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  networking.hostName = "zbornak";

  services.autorandr.enable = true;

  # HiDPI display (2880x1920 @ 13") - 1.5x scaling
  # Xft.dpi is the login-time default (laptop-only); autorandr postswitch
  # hooks update it dynamically when switching profiles.
  home-manager.users.dave = {
    xresources.properties."Xft.dpi" = "144";
    home.file.".config/ghostty/config.local".text = ''
      font-size = 12
    '';
    home.file.".config/kitty/local.conf".text = ''
      font_size 12.0
    '';

    programs.autorandr = {
      enable = true;
      profiles = {
        # Laptop screen only (no external monitor connected)
        laptop = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0009e5b40c0000000034210104a51d1378070aa5a7554b9f250c505400000001010101010101010101010101010101119140a0b0807470302036001dbe1000001a000000fd001e78f4f44a010a202020202020000000fe00424f45204e4a0a202020202020000000fc004e4531333541314d2d4e59310a023170207902002000139a0e00b40c000000003417074e4531334e593121001d220b6c07400b8007886efa54b8749f56820c023554d05fd05f483512782200144c550b883f0b9f002f001f007f077300020005002500094c550b4c550b1e7880810013721a000003011e7800006a426a427800000000000000000000000000004f907020790000260009020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003690";
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "2880x1920";
              rate = "120.00";
            };
          };
          hooks.postswitch = ''
            echo "Xft.dpi: 144" | xrdb -merge
            for sock in /tmp/kitty-*; do
              kitty @ --to "unix:$sock" set-font-size 12.0 2>/dev/null || true
            done
            i3-msg restart
          '';
        };

        # External monitor only (DELL U4025QW, 5120x2160 ultrawide)
        external = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0009e5b40c0000000034210104a51d1378070aa5a7554b9f250c505400000001010101010101010101010101010101119140a0b0807470302036001dbe1000001a000000fd001e78f4f44a010a202020202020000000fe00424f45204e4a0a202020202020000000fc004e4531333541314d2d4e59310a023170207902002000139a0e00b40c000000003417074e4531334e593121001d220b6c07400b8007886efa54b8749f56820c023554d05fd05f483512782200144c550b883f0b9f002f001f007f077300020005002500094c550b4c550b1e7880810013721a000003011e7800006a426a427800000000000000000000000000004f907020790000260009020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003690";
            DP-7 = "00ffffffffffff0010ac08434c3932300b230104b55d27783bd9a5b04f3db1240e5054a54b00714f81008180a940b300d1c0d100e1c0d44600a0a0381f4030203a00a1883100001a000000ff00434e53583933340a2020202020000000fc0044454c4c20553430323551570a000000fd0c3078191996010a202020202020021e02031ff152c17e7b6661605f5e5d101f04131211030201230907078301000050d000a0f0703e8030203500a1883100001a565e00a0a0a0295030203500a1883100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094701279030001000c4d24500f001470081078899903013cf8120186ff139f002f801f006f083d000200090013440206ff137b01a38057006f0859000780090091870006ff139f002f801f006f081e0002000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c90";
          };
          config = {
            eDP-1.enable = false;
            DP-7 = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "5120x2160";
              rate = "60.00";
            };
          };
          hooks.postswitch = ''
            echo "Xft.dpi: 96" | xrdb -merge
            for sock in /tmp/kitty-*; do
              kitty @ --to "unix:$sock" set-font-size 10.0 2>/dev/null || true
            done
            i3-msg restart
          '';
        };
      };
    };
  };

  # Enable firmware updates (recommended for Framework laptops)
  services.fwupd.enable = true;

  powerManagement.enable = true;
  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    HibernateDelaySec=2h
  '';

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  boot.kernelParams = [ "resume=/dev/disk/by-uuid/5921c9da-4108-4349-a03b-6cb0bee86251" ];

  system.stateVersion = "25.11";
}
