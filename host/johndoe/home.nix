{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "fistanto";
  home.homeDirectory = "/home/fistanto";

  fonts.fontconfig.enable = true;

  imports = [
    ../../home
    ./app/hyprland
  ];
  _module.args = {inherit inputs;};
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/fistanto/.dotfiles";
  };
  services.blueman-applet.enable = true;

  programs.git = {
    userEmail = "fistanto@ibr.cs.tu-bs.de";
  };

  sops = {
    age.keyFile = "/home/fistanto/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets."email/ibr" = {};
  };

  programs.ssh = {
    matchBlocks = {
      "proxy.lab.sra" = {
        hostname = "lab.sra.uni-hannover.de";
        user = "pas.fistanto";
        identityFile = "~/.ssh/sra-labor";
      };
      "lab.sra" = {
        hostname = "lab-pc32";
        proxyJump = "proxy.lab.sra";
        user = "pas.fistanto";
        identityFile = "~/.ssh/sra-labor";
      };
      "verliernix.sra" = {
        hostname = "verliernix";
        proxyJump = "proxy.lab.sra";
        user = "pas.fistanto";
        identityFile = "~/.ssh/sra-labor";
      };
      "llzero-vm" = {
        hostname = "localhost";
        port = 5555;
        user = "root";
        identityFile = "~/.ssh/debian-vm";
      };
      "debian-local" = {
        hostname = "debian.local";
        user = "root";
        identityFile = "~/src/asynczero-dev/bare-metal/deb-green";
      };
      "x1.ibr" = {
        hostname = "x1.ibr.cs.tu-bs.de";
        user = "fistanto";
        identityFile = "~/.ssh/fistanto-x1";
      };
      "orwa.ibr" = {
        hostname = "orwa";
        proxyJump = "x1.ibr";
        user = "fistanto";
        identityFile = "~/.ssh/fistanto-orwa";
      };
      "terabithia" = {
        hostname = "v2202508291507368807.luckysrv.de";
        user = "root";
        identityFile = "~/.ssh/terabithia";
      };
      "hal" = {
        hostname = "10.100.0.2";
        user = "root";
        proxyJump = "terabithia";
        identityFile = "~/.ssh/hal";
      };
      "saturn.remote" = {
        hostname = "saturn.local";
        user = "sisyph0s";
        proxyJump = "hal.remote";
        identityFile = "~/.ssh/sisyph0s@saturn";
      };
    };
  };
}
