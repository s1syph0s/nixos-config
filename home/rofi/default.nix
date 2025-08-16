{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.rofi = {
    enable = true;
    theme = ./themes/squared.rasi;
    font = "JetBrainsMono Nerd Font 12";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    extraConfig = {
      drun-match-fields = "name";
    };
  };
  home.packages = with pkgs; [
    rofi-rbw-wayland
  ];
}
