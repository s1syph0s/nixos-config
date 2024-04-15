{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs-unstable.legacyPackages.${system};

      overlay-unstable = final: prev: {
	unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
    in {
      nixosConfigurations = {
        saturn-vm = lib.nixosSystem {
	  inherit system;
	  modules = [
	  ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
	  ./configuration.nix
	  ];
	};
      };
      homeConfigurations = {
        sisyph0s = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
	  modules = [ ./home.nix ];
	};
      };
    };
}
