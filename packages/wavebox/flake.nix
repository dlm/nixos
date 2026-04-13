{
  description = "Wavebox browser package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation rec {
        pname = "wavebox";
        version = "10.147.44-2";

        src = pkgs.fetchurl {
          url = "https://download.wavebox.app/stable/linux/appimage/Wavebox_${version}_x86_64.AppImage";
          hash = "sha256-ZJGwoYtVC2uH+wHbFHdcUjz2KDa84siDh3uLvrye75U=";
        };

        nativeBuildInputs = [ pkgs.appimage-run ];

        dontUnpack = true;
        dontStrip = true;
        dontPatchELF = true;

        installPhase = ''
          install -D $src $out/bin/wavebox.AppImage

          cat > $out/bin/wavebox << WRAPPER
          #!${pkgs.runtimeShell}
          exec ${pkgs.appimage-run}/bin/appimage-run $out/bin/wavebox.AppImage "\$@"
          WRAPPER
          chmod +x $out/bin/wavebox

          install -Dm644 ${./wavebox.png} $out/share/pixmaps/wavebox.png

          mkdir -p $out/share/applications
          cat > $out/share/applications/wavebox.desktop << DESKTOP
          [Desktop Entry]
          Name=Wavebox
          Exec=$out/bin/wavebox
          Icon=$out/share/pixmaps/wavebox.png
          Type=Application
          Categories=Network;WebBrowser;
          DESKTOP
        '';

        meta = with pkgs.lib; {
          description = "Wavebox browser (AppImage) wrapped for Nix/NixOS";
          homepage = "https://wavebox.io/";
          license = licenses.unfree;
          platforms = platforms.linux;
        };
      };
    };
}
