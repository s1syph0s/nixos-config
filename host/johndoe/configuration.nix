# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common
    inputs.home-manager.nixosModules.home-manager
  ];

  users.users.fistanto = {
    isNormalUser = true;
    description = "fistanto";
    extraGroups = ["libvirtd" "networkmanager" "wheel" "dialout" "tty" "docker" "gamemode" "video"];
    packages = with pkgs; [
      firefox
      swayidle
      swaylock
    ];
  };

  networking.hostName = "johndoe"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.blueman.enable = true;
  services.printing.clientConf = ''
    ServerName cups.ibr.cs.tu-bs.de
  '';

  services.hardware.bolt.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [inputs.sops-nix.homeManagerModules.sops];
    users = {
      fistanto = import ./home.nix;
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nvme-cli
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
