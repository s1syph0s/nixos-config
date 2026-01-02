{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";

    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    anyrun.url = "github:anyrun-org/anyrun";
    zjstatus.url = "github:dj95/zjstatus";
    nixarr.url = "github:rasmus-kirk/nixarr";
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default # or deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };
    in
    {
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
            inputs.nixos-hardware.nixosModules.dell-precision-3490-intel
          ];
        };

        hal = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./host/hal/configuration.nix
            ./pkgs/overlay.nix
            ./modules/immich.nix
            ./modules/postgres.nix
            inputs.sops-nix.nixosModules.sops
            inputs.nixarr.nixosModules.default
          ];
        };

        terabithia = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./host/terabithia/configuration.nix
            ./pkgs/overlay.nix
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
        };
      };

      deploy.nodes = {
        hal = {
          hostname = "hal";
          profiles.system = {
            sshUser = "root";
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.hal;
          };
        };
        terabithia = {
          hostname = "terabithia";
          profiles.system = {
            sshUser = "root";
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.terabithia;
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
