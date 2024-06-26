{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      overlays = [
	(self: super: {
	  hypr-kblayout = super.callPackage ./pkgs/hypr-kblayout { };
	})
      ];
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
	inherit system overlays;
      };
    in {
      nixosConfigurations = {
        saturn-vm = lib.nixosSystem {
	  inherit system;
	  modules = [ ./host/saturn-vm/configuration.nix ];
	};
        saturn = lib.nixosSystem {
	  inherit system;
	  modules = [ ./host/saturn/configuration.nix ];
	};
        greenbox = lib.nixosSystem {
	  inherit system;
	  modules = [ ./host/greenbox/configuration.nix ];
	};
      };
      homeConfigurations = {
        "sisyph0s@saturn-vm" = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
	  modules = [ ./host/saturn-vm/home.nix ];
	};
        "sisyph0s@saturn" = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
	  modules = [ ./host/saturn/home.nix ];
	};
        "sisyph0s@greenbox" = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
	  modules = [ ./host/greenbox/home.nix ];
	};
      };
    };
}
