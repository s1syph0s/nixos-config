{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sisyph0s";
  home.homeDirectory = "/home/sisyph0s";

  fonts.fontconfig.enable = true;

  imports = [
    ../../home
    ./app/hyprland
  ];
  _module.args = {inherit inputs;};
  home.packages = with pkgs; [
    drawio
  ];
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
    flake = "/home/sisyph0s/.dotfiles";
  };
  programs.ssh = {
    matchBlocks = {
      "hal" = {
        hostname = "hal.local";
        user = "root";
        identityFile = "~/.ssh/hal";
      };
      "terabithia" = {
        hostname = "v2202508291507368807.luckysrv.de";
        user = "root";
        identityFile = "~/.ssh/terabithia";
      };
    };
  };
}
