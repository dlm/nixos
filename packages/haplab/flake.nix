{
  description = "Haplab AI development tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux = {
        sidecar = pkgs.callPackage ./sidecar.nix { };
        td = pkgs.callPackage ./td.nix { };
        default = self.packages.x86_64-linux.sidecar;
      };
    };
}
