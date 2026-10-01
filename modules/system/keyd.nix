{ lib, config, ... }:
let
  cfg = config.hardware.keyboard.laptop-remap;
in
{
  options.hardware.keyboard.laptop-remap.enable =
    lib.mkEnableOption "keyd-based keyboard remapping for the built-in laptop keyboard (alt/meta swap, caps tap-hold)";

  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards.builtin = {
        ids = [ "0001:0001" ];
        settings.main = {
          leftalt = "leftmeta";
          leftmeta = "leftalt";
          rightalt = "rightmeta";
          rightmeta = "rightalt";
          capslock = "overload(control, esc)";
        };
      };
    };
  };
}
