{
  description = "Nixos config flake";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    llm-agents.url = "github:numtide/llm-agents.nix";
    muxwm.url = "github:dlm/muxwm";
    haplab.url = "path:./packages/haplab";
    wavebox.url = "path:./packages/wavebox";
    key-safe = {
      url = "path:/home/dave/repos/dlm/key-safe";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.petrillo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/petrillo/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
        ];
      };

      nixosConfigurations.zbornak = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/zbornak/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
