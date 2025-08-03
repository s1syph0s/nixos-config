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

  users.users.sisyph0s = {
    isNormalUser = true;
    description = "sisyph0s";
    extraGroups = ["libvirtd" "networkmanager" "wheel" "dialout" "tty" "docker" "gamemode"];
    packages = with pkgs; [
      firefox
      swayidle
      swaylock
    ];
  };

  networking.hostName = "saturn"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.extraHosts = ''
    192.168.0.226 vault.hal.com
    192.168.0.226 paperless.hal.com
    192.168.0.226 pad.hal.com
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.pipewire.extraConfig.pipewire-pulse."92-baldurs-gate" = {
    context.modules = [
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          pulse.min.req = "32/44100";
          pulse.default.req = "32/44100";
          pulse.max.req = "32/44100";
          pulse.min.quantum = "32/44100";
          pulse.max.quantum = "32/44100";
          audio.format = "S24LE"; # 24-bit audio
        };
      }
    ];
    stream.properties = {
      node.latency = "32/44100";
      resample.quality = 1;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
      "drawio"
      "spotify"
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      sisyph0s = import ./home.nix;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
