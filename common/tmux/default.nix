{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    prefix = "C-Space";
    keyMode = "vi";
    terminal = "tmux-256color";
    baseIndex = 1;
    shell = "${pkgs.fish}/bin/fish";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
    extraConfig = ''
      set -s escape-time 0
      bind-key C-Space send-prefix
      set -g status-style 'bg=#333333 fg=#5eacd3'
    '';
  };
}
