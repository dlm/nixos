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
  ];

  networking.hostName = "petrillo";
  services.autorandr.enable = true;

  home-manager.users.dave = {
    home.file.".config/ghostty/config.local".text = ''
      font-size = 10
    '';
    home.file.".config/kitty/local.conf".text = ''
      font_size 10.0
    '';

    programs.autorandr = {
      enable = true;
      profiles = {
        # Laptop screen only (no external monitor connected)
        laptop = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0030e4080600000000001c0104a51f117802e085a3544e9b260e5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001a542b80a070381f403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746392d5350463100d5";
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "1920x1080";
              rate = "60.02";
            };
          };
          hooks.postswitch = ''
            i3-msg restart
            systemctl --user restart feh-background.service
          '';
        };

        # External monitor only (DELL U4025QW, 5120x2160 ultrawide)
        external = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0030e4080600000000001c0104a51f117802e085a3544e9b260e5054000000010101010101010101010101010101012e3680a070381f403020350035ae1000001a542b80a070381f403020350035ae1000001a000000fe004c4720446973706c61790a2020000000fe004c503134305746392d5350463100d5";
            DP-1 = "00ffffffffffff0010ac08434c3932300b230104b55d27783bd9a5b04f3db1240e5054a54b00714f81008180a940b300d1c0d100e1c0d44600a0a0381f4030203a00a1883100001a000000ff00434e53583933340a2020202020000000fc0044454c4c20553430323551570a000000fd0c3078191996010a202020202020021e02031ff152c17e7b6661605f5e5d101f04131211030201230907078301000050d000a0f0703e8030203500a1883100001a565e00a0a0a0295030203500a1883100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094701279030001000c4d24500f001470081078899903013cf8120186ff139f002f801f006f083d000200090013440206ff137b01a38057006f0859000780090091870006ff139f002f801f006f081e0002000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c90";
          };
          config = {
            eDP-1.enable = false;
            DP-1 = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "5120x2160";
              rate = "60.00";
            };
          };
          hooks.postswitch = ''
            i3-msg restart
            systemctl --user restart feh-background.service
          '';
        };
      };

    };

  };

  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.hardware.bolt.enable = true;

  nix.settings.secret-key-files = [ "/home/dave/.config/nix/signing-key.sec" ];

  system.stateVersion = "24.11";
}
