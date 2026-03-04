{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "td";
  version = "0.41.0";

  src = fetchurl {
    url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_linux_amd64.tar.gz";
    hash = "sha256-XJxy1R3evUgJvx+NNhTbOmDryNvGvGK6/Lq/goOsFkY=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 td $out/bin/td

    runHook postInstall
  '';

  meta = with lib; {
    description = "A minimalist CLI for tracking tasks across AI coding sessions";
    homepage = "https://td.haplab.com/";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "td";
    platforms = [ "x86_64-linux" ];
  };
}
