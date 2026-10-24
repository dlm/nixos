{ lib, config, ... }:
{
  options.home.localConfig = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    default = { };
    description = ''
      Host-specific "local" config snippets for apps whose main config is an
      out-of-store symlink into the env repo (e.g. kitty, ghostty). Keyed by
      app name; each value is written to `~/.config/<name>-local.conf`.

      This deliberately lands *outside* the app's symlinked config directory
      (e.g. not inside `~/.config/kitty/`), since home-manager refuses to
      install a managed file that resolves outside $HOME through a directory
      symlink -- which is exactly what a path like `.config/kitty/local.conf`
      does when `~/.config/kitty` is itself a symlink out to the env repo.

      The app's own config is expected to pull this in by absolute path
      (kitty: `include`, ghostty: `config-file`), same idea as how niri's
      `stacks.desktop-niri.outputConfig` gets pulled into env/niri/config.kdl.
    '';
    example = {
      kitty = "font_size 12.0";
      ghostty = "font-size = 12";
    };
  };

  config = {
    xdg.configFile = lib.mapAttrs' (
      name: text: lib.nameValuePair "${name}-local.conf" { inherit text; }
    ) config.home.localConfig;
  };
}
