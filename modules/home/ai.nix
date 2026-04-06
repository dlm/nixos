{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  ai-tools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  haplab = inputs.haplab.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options = {
    home.ai.enable = lib.mkEnableOption "enables ai tooling";
  };

  config = lib.mkIf config.home.ai.enable {
    home.packages = with pkgs; [
      ai-tools.gemini-cli
      ai-tools.claude-code
      ai-tools.codex

      haplab.td
    ];
  };
}
