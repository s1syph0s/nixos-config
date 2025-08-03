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
    secrets."terabithia/wg/public" = {};
    secrets."terabithia/wg/private" = {};
  };

  # networking.nat = {
  #   enable = true;
  #   externalInterface = "ens3";
  #   internalInterfaces = ["wg0"];
  # };
  # networking.firewall.allowedUDPPorts = [51820];

  # networking.wireguard = {
  #   enable = true;
  #   interfaces = {
  #     wg0 = {
  #       # WireGuard interface IP on VPS (server side)
  #       ips = ["10.100.0.1/24"];

  #       # Listen port on VPS
  #       listenPort = 51820;

  #       # NAT and forwarding rules to send HTTP/HTTPS to home server via WireGuard
  #       postSetup = ''
  #         ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE

  #         # Forward ports 80 and 443 to home server (WireGuard client IP)
  #         ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.100.0.2:80
  #         ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 10.100.0.2:443

  #         # Allow forwarding for the incoming packets
  #         ${pkgs.iptables}/bin/iptables -A FORWARD -p tcp -d 10.100.0.2 --dport 80 -j ACCEPT
  #         ${pkgs.iptables}/bin/iptables -A FORWARD -p tcp -d 10.100.0.2 --dport 443 -j ACCEPT
  #       '';

  #       postShutdown = ''
  #         ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE

  #         ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.100.0.2:80
  #         ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -p tcp --dport 443 -j DNAT --to-destination 10.100.0.2:443

  #         ${pkgs.iptables}/bin/iptables -D FORWARD -p tcp -d 10.100.0.2 --dport 80 -j ACCEPT
  #         ${pkgs.iptables}/bin/iptables -D FORWARD -p tcp -d 10.100.0.2 --dport 443 -j ACCEPT
  #       '';

  #       privateKeyFile = "/path/to/vps/privatekey";

  #       peers = [
  #         {
  #           name = "Home Server";
  #           publicKey = "CLIENT_PUBLIC_KEY_HERE";
  #           allowedIPs = ["10.100.0.2/32"]; # home server WireGuard IP
  #         }
  #       ];
  #     };
  #   };
  # };

  environment.systemPackages = with pkgs; [
    wget
    wireguard-tools
    curl
    git
    gnumake
    man-pages
    man-pages-posix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "25.05";
}
