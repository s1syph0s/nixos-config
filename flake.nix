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
    nixos-hardware,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    overlays = [
      (self: super: {
        hypr-kblayout = super.callPackage ./pkgs/hypr-kblayout {};
        openssh = super.openssh.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./patch/openssh.patch];
          doCheck = false;
        });
        zjstatus = inputs.zjstatus.packages.${self.system}.default;
      })
    ];
    pkgs = import nixpkgs {
      inherit system;
    };
    pkgs-overlay = {
      nixpkgs.overlays = overlays;
    };
  in {
    nixosConfigurations = {
      saturn-vm = lib.nixosSystem {
        inherit system;
        modules = [./host/saturn-vm/configuration.nix];
      };
      saturn = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./host/saturn/configuration.nix
          pkgs-overlay
        ];
      };
      greenbox = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./host/greenbox/configuration.nix
          pkgs-overlay
        ];
      };
      johndoe = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./host/johndoe/configuration.nix
          pkgs-overlay
          nixos-hardware.nixosModules.dell-precision-3490
        ];
      };
    };
    homeConfigurations = {
      "sisyph0s@saturn-vm" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./host/saturn-vm/home.nix
        ];
      };
    };
  };
}
