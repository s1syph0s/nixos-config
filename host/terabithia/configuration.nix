{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.loader.grub.enable = true;
  services.openssh.enable = true;

  users.users.root = {
    initialHashedPassword = "$y$j9T$TiPYI3DDO0wYPv0jaOGhQ0$/DTwieWqqKA4.xtLKDiKQOTKtYdvzxfyaRLTN2SVeqB";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPdOPyuU3TFfLU7fwjjaf3X8peBiTQAaX6pN8XfIkKW terabithia"
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets."terabithia/wg/private" = {};
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = ["wg0"];
    forwardPorts = [
      {
        sourcePort = 80;
        proto = "tcp";
        destination = "10.100.0.2:80"; # IP of HAL behind wg0
      }
      {
        sourcePort = 443;
        proto = "tcp";
        destination = "10.100.0.2:443";
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [
    22 #ssh
    80 #http
    443 #https
  ];
  networking.firewall.allowedUDPPorts = [
    51820 # wireguard
  ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        # WireGuard interface IP on VPS (server side)
        ips = ["10.100.0.1/24"];
        mtu = 1280;

        # Listen port on VPS
        listenPort = 51820;
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
        '';

        privateKeyFile = config.sops.secrets."terabithia/wg/private".path;

        peers = [
          {
            name = "HAL";
            publicKey = "6SNtOxOdRiNHG16/QcVVM+trc6NvEwp2CbBSrdHw/Tc=";
            allowedIPs = ["10.100.0.2/32"]; # home server WireGuard IP
          }
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    wireguard-tools
    tcpdump
    curl
    git
    gnumake
    man-pages
    man-pages-posix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "25.05";
}
