{
  config,
  lib,
  pkgs,
  hostHome,
  agentUid,
  agentPubKey,
  ...
}: let
  vmUser = "clanker"; # login name inside the VM; the only place it is set

  # hostHome comes from the host (Home Manager); it is only used for the share,
  # so the path is identical on both sides.
  guestHome = "/home/${vmUser}"; # the VM user's real home
in {
  system.stateVersion = "25.11"; # set to the release you actually use
  networking.hostName = "clanker-vm";
  nixpkgs.config.allowUnfree = true; # claude-code is unfree
  documentation.enable = false;

  ## ---------------------------------------------------------------- microVM
  microvm = {
    hypervisor = "qemu"; # supports 9p + user-mode networking + port forwarding
    vcpu = 4;
    mem = 4096; # MiB

    # User-mode networking: no root, no bridge. Outbound traffic is unrestricted.
    interfaces = [
      {
        type = "user";
        id = "clanker-vm";
        mac = "02:00:00:00:00:01";
      }
    ];

    # host 127.0.0.1:6769 -> guest :22. Bind to loopback ONLY.
    forwardPorts = [
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 6769;
        guest.port = 22;
      }
    ];

    # No virtiofs: microvm.nix runs virtiofsd under a supervisor that needs root.
    # The Nix store comes from a read-only disk image built with the guest.
    storeOnDisk = true;

    shares = [
      {
        # the ONLY host directory the agent can see. Same absolute path on both
        # sides, so paths in ACP messages match what Emacs sees.
        # 9p is served by qemu itself, as your user, so no daemon or root is needed.
        tag = "agent";
        proto = "9p";
        source = hostHome + "/agent";
        mountPoint = hostHome + "/agent";
      }
    ];

    # Lets the guest build/realise things without touching the host store.
    writableStoreOverlay = "/nix/.rw-store";

    # Disk images are created next to where the runner is started
    # (clankerctl runs it from ~/.local/state/agent-vm).
    volumes = [
      {
        image = "nix-rw.img";
        mountPoint = "/nix/.rw-store";
        size = 16384;
      }
      {
        # agent login, history, caches, nix-direnv caches: all persistent
        image = "home.img";
        mountPoint = guestHome;
        size = 8192;
      }
      {
        # persistent sshd host key, so ssh doesn't complain after VM recreation
        image = "sshd.img";
        mountPoint = "/etc/ssh-persist";
        size = 32;
      }
    ];
  };

  ## --------------------------------------------------------------- network
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
  };
  services.resolved.enable = true;

  ## ----------------------------------------------------------------- users
  users.users.${vmUser} = {
    isNormalUser = true;
    uid = agentUid; # keep equal to your host uid, so ownership looks the same on both sides
    home = guestHome;
    openssh.authorizedKeys.keys = [agentPubKey];
    # deliberately not in "wheel": no sudo for the agent
  };

  # A fresh ext4 volume mounted over the home dir is root-owned; fix it up.
  systemd.tmpfiles.rules = [
    "d ${guestHome} 0700 ${vmUser} users -"
  ];

  ## ------------------------------------------------------------------- ssh
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [vmUser];
    };
    hostKeys = [
      {
        path = "/etc/ssh-persist/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  ## -------------------------------------------------------------- tooling
  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    openssh
    curl
    jq
    ripgrep
    fd
    claude-code # for the one-time login, and as the agent itself
    claude-agent-acp # ACP adapter that agent-shell talks to (from nixpkgs)
  ];
}
