{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:anyrun-org/anyrun";

    zjstatus = {url = "github:dj95/zjstatus";};
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    zjstatus,
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
        zjstatus = zjstatus.packages.${self.system}.default;
      })
    ];
    # pkgs = nixpkgs.legacyPackages.${system};
    pkgs = import nixpkgs {inherit system overlays;};
  in {
    nixosConfigurations = {
      saturn-vm = lib.nixosSystem {
        inherit system;
        modules = [./host/saturn-vm/configuration.nix];
      };
      saturn = lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./host/saturn/configuration.nix
        ];
      };
      greenbox = lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./host/greenbox/configuration.nix
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
      "sisyph0s@saturn" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./host/saturn/home.nix
        ];
      };
      "sisyph0s@greenbox" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./host/greenbox/home.nix
        ];
      };
    };
  };
}
