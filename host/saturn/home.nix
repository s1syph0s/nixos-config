{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sisyph0s";
  home.homeDirectory = "/home/sisyph0s";

  fonts.fontconfig.enable = true;

  imports = [
    ../../common
    ./app/hyprland
  ];
  home.packages = with pkgs; [
    drawio
  ];
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

}
