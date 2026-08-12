{
  config,
  pkgs,
  ...
}: {
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
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_flavor "macchiato"
          set -g status-position "top"
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -g @catppuccin_window_text " #{s|^$HOME|~|:pane_current_path}"
          set -g @catppuccin_window_current_text " #{s|^$HOME|~|:pane_current_path}"
        '';
      }
    ];
    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",xterm-ghostty:Tc"

      set -g allow-passthrough on

      set -s escape-time 0
      bind-key C-Space send-prefix

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

      bind '"' split-window -v -c "#{pane_current_path}"
      bind '%' split-window -h -c "#{pane_current_path}"
      bind 'c' new-window -c "#{pane_current_path}"
      bind 'r' source-file ~/.config/tmux/tmux.conf
    '';
  };
}
