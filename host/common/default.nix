{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };

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

  documentation.man = {
    enable = true;
    generateCaches = true;
  };

  services.gnome = {
    gnome-keyring.enable = true;
    gcr-ssh-agent.enable = false;
  };
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session --user-menu --asterisks -r --remember-user-session";
        user = "greeter";
      };
    };
  };
  services.protonmail-bridge = {
    enable = true;
    logLevel = "info";
    path = with pkgs; [ gnome-keyring ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  security.pam.services.hyprlock = { };

  services.udisks2.enable = true;

  services.envfs.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        reaper_freq = 5;
      };
      cpu = {
        park_cores = "no";
        pin_cores = "no";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    home-manager
    pulseaudio
    lshw
    networkmanagerapplet

    # nixos utils
    nix-output-monitor
    nvd

    gnumake
    openssl

    sshfs
    libsecret

    dmidecode
    amdgpu_top

    linux-manual
    man-pages
    man-pages-posix

    playerctl
  ];

  programs.niri.enable = true;

  programs.nix-ld.enable = true;

  programs.seahorse.enable = true;

  programs.virt-manager.enable = true;

  programs.command-not-found.enable = false;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  #nix LSP
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  environment.variables.EDITOR = "neovim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };
  services.pcscd.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8384 ];
  networking.firewall.allowedUDPPorts = [ 24727 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.udev = {
    enable = true;
    packages = [
      pkgs.via
      (pkgs.writeTextFile {
        name = "microbit-udev-rules";
        text = ''
          # CMSIS-DAP for microbit

          ACTION!="add|change", GOTO="microbit_rules_end"

          SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", TAG+="uaccess"

          LABEL="microbit_rules_end"
        '';
        destination = "/etc/udev/rules.d/69-microbit.rules";
      })
      (pkgs.writeTextFile {
        name = "rp2040-udev-rules";
        text = ''
          # RP2040 / MicroPython FS mode
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0005", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/69-rp2040.rules";
      })
    ];
  };

  services.locate.enable = true;
  services.locate.package = pkgs.mlocate;

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

  services.trezord.enable = true;

  hardware.keyboard.qmk.enable = true;

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

  # enable wireguard
  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 1637 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 1637 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 1637 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 1637 -j RETURN || true
    '';
  };
}
