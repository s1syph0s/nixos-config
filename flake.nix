{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-neovim-patch.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    envfs.url = "github:Mic92/envfs";
    envfs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-ld, envfs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      overlays = [
	(self: super: {
	  hypr-kblayout = super.callPackage ./pkgs/hypr-kblayout { };
	  openssh = super.openssh.overrideAttrs ( old: {
	    patches = (old.patches or [ ]) ++ [ ./patch/openssh.patch ];
	    doCheck = false;
	  });
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
	  specialArgs = {
	    inherit inputs;
	  };
	  modules = [ 
	    ./host/saturn/configuration.nix

	    nix-ld.nixosModules.nix-ld
	    { programs.nix-ld.dev.enable = true; }

	    envfs.nixosModules.envfs
	  ];
	};
        greenbox = lib.nixosSystem {
	  inherit system;
	  specialArgs = {
	    inherit inputs;
	  };
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
	  extraSpecialArgs = {
              inherit inputs;
          };
	  modules = [ 
	    ./host/saturn/home.nix 
	    inputs.anyrun.homeManagerModules.anyrun
	  ];
	};
        "sisyph0s@greenbox" = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
	  extraSpecialArgs = {
              inherit inputs;
          };
	  modules = [ 
	    ./host/greenbox/home.nix
	    inputs.anyrun.homeManagerModules.anyrun
	  ];
	};
      };
    };
}
