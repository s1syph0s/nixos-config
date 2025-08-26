{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.waybar = {
    enable = true;
  };

  xdg.configFile."waybar" = {
    source = ./config;
  };
}
