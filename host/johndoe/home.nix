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
    };
  };
}
