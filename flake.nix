{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:anyrun-org/anyrun";
    zjstatus.url = "github:dj95/zjstatus";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      saturn = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./host/saturn/configuration.nix
          ./pkgs/overlay.nix
        ];
      };
      greenbox = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./host/greenbox/configuration.nix
          ./pkgs/overlay.nix
        ];
      };
      johndoe = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./host/johndoe/configuration.nix
          ./pkgs/overlay.nix
          inputs.nixos-hardware.nixosModules.dell-precision-3490
        ];
      };
    };
  };
}
