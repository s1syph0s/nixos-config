# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./backup.nix

    ../../services/vaultwarden.nix
    ../../services/hedgedoc.nix
    ../../services/ldap.nix
    ../../services/immich.nix
    ../../services/authelia.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  networking.hostName = "hal"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
    ];

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
    };
  };

  services.logind.lidSwitch = "ignore";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [8384];
  networking.firewall.allowedUDPPorts = [
    51820 # wireguard
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."hal/wg/private" = { };
    secrets."transmission/airvpn-nl.conf" = {
      owner = config.users.users.transmission.name;
    };
  };

  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg1 = {
        # WireGuard interface IP on VPS (server side)
        ips = [ "10.100.0.2/24" ];
        mtu = 1280;

        # Listen port on VPS
        listenPort = 51820;

        privateKeyFile = config.sops.secrets."hal/wg/private".path;

        peers = [
          {
            name = "Terabithia";
            publicKey = "osE3KSQK8Y7y54CTBzKVgnxT4UYAr3PXeQdpViccRnE=";
            allowedIPs = [ "10.100.0.0/24" ]; # home server WireGuard IP
            endpoint = "185.194.141.148:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    vpn = {
      enable = true;
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      wgConf = config.sops.secrets."transmission/airvpn-nl.conf".path;
    };

    jellyfin = {
      enable = true;
    };

    transmission = {
      enable = true;
      uiPort = 9090;
      vpn.enable = true;
      peerPort = 49517; # Set this to the port forwarded by your VPN
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
  };
  services.flaresolverr.enable = true;

  services.internal.backup.serviceNames = [
    "bazarr"
    "lidarr"
    "prowlarr"
    "radarr"
    "readarr"
    "sonarr"
    "transmission"
  ];

  virtualisation.containers.enable = true;
  # docker
  # virtualisation.docker = {
  #   enable = true;
  # };

  # podman
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  # virt manager
  virtualisation.libvirtd.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    gnumake
    man-pages
    man-pages-posix

    tcpdump
    openldap

    file

    tmux
    fish
  ];

  programs.bash = {
    interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "24h";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
