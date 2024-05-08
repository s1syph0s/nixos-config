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
      pkgs = nixpkgs.legacyPackages.${system};
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
	  modules = [ ./home.nix ];
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
