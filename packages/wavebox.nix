{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  pname = "wavebox";
  version = "10.138.14-2";

  src = pkgs.fetchurl {
    url = "https://download.wavebox.app/stable/linux/appimage/Wavebox_${version}_x86_64.AppImage";
    sha256 = "8326336c3cf642da91534e4abc96a6b8d975f24f9db5b0121b81c1217ed5dfda";
  };

  nativeBuildInputs = [ pkgs.appimage-run ];

  dontUnpack = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/wavebox.AppImage
    chmod +x $out/bin/wavebox.AppImage

    # create a wrapper that runs it via appimage-run
    cat > $out/bin/wavebox <<EOF
    #!${pkgs.runtimeShell}
    sha256sum $out/bin/wavebox.AppImage
    exec ${pkgs.appimage-run}/bin/appimage-run $out/bin/wavebox.AppImage "\$@"
    EOF

    chmod +x $out/bin/wavebox

    # Desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/wavebox.desktop <<EOF
    [Desktop Entry]
    Name=Wavebox
    Exec=$out/bin/wavebox
    Icon=wavebox
    Type=Application
    Categories=Network;WebBrowser;
    EOF
  '';

  meta = with pkgs.lib; {
    description = "Wavebox browser (AppImage) wrapped for Nix/NixOS";
    homepage = "https://wavebox.io/";
    # license = licenses.unfree;
    platforms = platforms.linux;
  };
}
