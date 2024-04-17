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
      set -ga terminal-overrides ",alacritty:Tc"
      set -s escape-time 0
      bind-key C-Space send-prefix
      set -g status-style 'bg=#333333 fg=#5eacd3'

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

      bind '"' split-window -v -c "#{pane_current_path}"
      bind '%' split-window -h -c "#{pane_current_path}"
      bind 'c' new-window -c "#{pane_current_path}"
    '';
  };
}
