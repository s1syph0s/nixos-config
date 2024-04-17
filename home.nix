{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sisyph0s";
  home.homeDirectory = "/home/sisyph0s";

  imports = [
    ./common/neovim
  ];
}
