{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.stacks.desktop-niri;
in
{
  options.stacks.desktop-niri = {
    enable = lib.mkEnableOption "desktop stack with niri (Wayland scrollable-tiling compositor)";

    outputConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Host-specific niri `output` blocks (KDL), e.g. monitor modes/scale/position.
        Unlike the X11/autorandr setup, niri scales each output independently and
        live, so laptop + external can both be enabled at once with no profile
        switching needed.

        This is Nix-generated (unlike the rest of the niri config, which is a
        plain out-of-store symlink to the env repo) because it's genuinely
        host-specific hardware data, same as the autorandr profiles it replaces.
        It's pulled into the main config via niri's native `include`.
      '';
      example = ''
        output "eDP-1" {
            mode "2880x1920@120.000"
            scale 2
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    # Required for swaylock to authenticate against PAM.
    security.pam.services.swaylock = { };

    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        home.packages = with pkgs; [
          alacritty
          xwayland-satellite # niri has built-in on-demand integration with this
          playerctl
          brightnessctl
          swaybg
          wdisplays # wayland equivalent of arandr

          # Wrapper so the (plain, nix-free) env/niri/config.kdl can spawn this
          # by bare name -- polkit_gnome's agent binary lives under libexec,
          # which isn't on PATH otherwise.
          (pkgs.writeShellScriptBin "polkit-agent" ''
            exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
          '')
        ];

        home.niri.enable = true;
        home.waybar.enable = true;
        home.fuzzel.enable = true;
        home.mako.enable = true;
        programs.swaylock.enable = true;

        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 600;
              command = "${pkgs.swaylock}/bin/swaylock -f";
            }
            {
              # Deliberately close behind the lock above (not e.g. 900s):
              # each timeout counts seconds-since-last-input independently,
              # so a long gap here means any single keystroke on the lock
              # screen (wrong password attempt, checking if it's locked)
              # resets both counters and this may never actually fire.
              timeout = 605;
              command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
              resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
            }
          ];
          events = {
            before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
            after-resume = "${pkgs.niri}/bin/niri msg action power-on-monitors";
          };
        };

        # Nix-generated, pulled in via `include` from config.kdl.
        xdg.configFile."niri/outputs.kdl".text = cfg.outputConfig;
      };
  };
}
