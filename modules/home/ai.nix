{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  ai-tools = inputs.nix-ai-tools.packages.${pkgs.system};
in
{
  options = {
    home.ai.enable = lib.mkEnableOption "enables ai tooling";
  };

  config = lib.mkIf config.home.ai.enable {
    home.packages = with pkgs; [
      gemini-cli
      claude-code
      ai-tools.codex
    ];
  };
}
