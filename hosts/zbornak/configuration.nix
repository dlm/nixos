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
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
  ];

  networking.hostName = "zbornak";

  services.autorandr.enable = true;

  # Trying niri as an alternative to i3 -- selectable as a separate session
  # from the lightdm login screen, doesn't replace the existing i3 setup.
  stacks.desktop-niri.enable = true;
  stacks.desktop-niri.outputConfig = ''
    // 2880x1920 @ 13" laptop panel (~257 ppi)
    output "eDP-1" {
        mode "2880x1920@120.000"
        scale 2
    }

    // DELL U4025QW, 5120x2160 ultrawide (~140 ppi)
    output "DP-1" {
        mode "5120x2160@120.000"
        scale 1.25
    }
  '';

  # HiDPI display (2880x1920 @ 13") - 1.5x scaling
  # Xft.dpi is the login-time default (laptop-only); autorandr postswitch
  # hooks update it dynamically when switching profiles.
  # services.xserver.dpi covers the X server itself (and therefore the
  # lightdm greeter, which runs before any user session/Xresources exist).
  services.xserver.dpi = 144;

  home-manager.users.dave = {
    xresources.properties."Xft.dpi" = "144";
    home.localConfig = {
      ghostty = "font-size = 12";
      kitty = "font_size 12.0";
    };

    programs.autorandr = {
      enable = true;
      profiles = {
        # Laptop screen only (no external monitor connected)
        laptop = {
          fingerprint = {
            eDP-1 = "00ffffffffffff000e7722130000000000230104b51c137803cc85a4554c9c240d505400000001010101010101010101010101010101da9040a0b0807170302066001dbe10000018000000fd001e78f4f44b010a202020202020000000fe0043534f54205433202020202020000000fc004d4e443530385a42312d310a20029c02032400e3058000e60605017a7a52741a000003531e7800207aff7aff780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033702079020020000c408bf622130000000000190021001d210b6c07400b8007804e0a55cde49b4a120d024554786178610047137822001406510b883f0b9f002f001f007f077000050005002600090600000000005000002b000c27001e77000027001e3b00002e0006004778617861000000000000000000000000000000fe90";
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
            i3-msg restart
            systemctl --user restart feh-background.service
          '';
        };

        # External monitor only (DELL U4025QW, 5120x2160 ultrawide)
        external = {
          fingerprint = {
            eDP-1 = "00ffffffffffff000e7722130000000000230104b51c137803cc85a4554c9c240d505400000001010101010101010101010101010101da9040a0b0807170302066001dbe10000018000000fd001e78f4f44b010a202020202020000000fe0043534f54205433202020202020000000fc004d4e443530385a42312d310a20029c02032400e3058000e60605017a7a52741a000003531e7800207aff7aff780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033702079020020000c408bf622130000000000190021001d210b6c07400b8007804e0a55cde49b4a120d024554786178610047137822001406510b883f0b9f002f001f007f077000050005002600090600000000005000002b000c27001e77000027001e3b00002e0006004778617861000000000000000000000000000000fe90";
            DP-1 = "00ffffffffffff0010ac08434c3932300b230104b55d27783bd9a5b04f3db1240e5054a54b00714f81008180a940b300d1c0d100e1c0d44600a0a0381f4030203a00a1883100001a000000ff00434e53583933340a2020202020000000fc0044454c4c20553430323551570a000000fd0c3078191996010a202020202020021e02031ff152c17e7b6661605f5e5d101f04131211030201230907078301000050d000a0f0703e8030203500a1883100001a565e00a0a0a0295030203500a1883100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094701279030001000c4d24500f001470081078899903013cf8120186ff139f002f801f006f083d000200090013440206ff137b01a38057006f0859000780090091870006ff139f002f801f006f081e0002000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c90";
          };
          config = {
            eDP-1.enable = false;
            DP-1 = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "5120x2160";
              rate = "120.00";
            };
          };
          hooks.postswitch = ''
            echo "Xft.dpi: 96" | xrdb -merge
            i3-msg restart
            systemctl --user restart feh-background.service
          '';
        };
      };
    };
  };

  # Enable firmware updates (recommended for Framework laptops)
  services.fwupd.enable = true;

  # backups
  stacks.backup = {
    enable = true;
    sshKeySopsPath = "hosts/zbornak/restic-ssh-key";
    passwordSopsPath = "hosts/zbornak/restic-password";
    paths = [
      "/home/dave/repos"
      "/home/dave/sync"
    ];
  };

  system.stateVersion = "25.11";
}
