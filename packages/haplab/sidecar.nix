{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "sidecar";
  version = "0.77.0";

  src = fetchurl {
    url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_linux_amd64.tar.gz";
    hash = "sha256-PXXRlHaresWxWgrDv1XUST7/DWEINAoGJotwp+mqJrQ=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 sidecar $out/bin/sidecar

    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal-based development tool integrating multiple AI coding agents";
    homepage = "https://sidecar.haplab.com/";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "sidecar";
    platforms = [ "x86_64-linux" ];
  };
}
