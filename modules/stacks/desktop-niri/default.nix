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

          # Wrapper so the (plain, nix-free) env/niri/config.kdl can spawn this
          # by bare name -- polkit_gnome's agent binary lives under libexec,
          # which isn't on PATH otherwise.
          (pkgs.writeShellScriptBin "polkit-agent" ''
            exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
          '')
        ];

        programs.waybar.enable = true;
        programs.fuzzel.enable = true;
        programs.swaylock.enable = true;

        services.mako.enable = true;

        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 600;
              command = "${pkgs.swaylock}/bin/swaylock -f";
            }
            {
              timeout = 900;
              command = "niri msg action power-off-monitors";
            }
          ];
        };

        # Hand-edited, hot-reloads on save -- same pattern as i3/rofi/kitty.
        xdg.configFile."niri/config.kdl".source =
          config.lib.file.mkOutOfStoreSymlink /home/dave/repos/dlm/env/niri/config.kdl;

        # Nix-generated, pulled in via `include` from config.kdl.
        xdg.configFile."niri/outputs.kdl".text = cfg.outputConfig;
      };
  };
}
