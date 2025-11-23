{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    home.ai.enable = lib.mkEnableOption "enables ai tooling";
  };

  config = lib.mkIf config.home.nushell.enable {
    home.packages = with pkgs; [
      gemini-cli
      claude-code
    ];
  };
}
