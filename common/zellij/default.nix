{ config, pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    # settings = {
    #   default_shell = "fish";
    #   copy_command = "wl-copy";
    #   keybinds = {
    #     unbind = [ "Ctrl g" ];
    #     shared_except = {
    #       _args = [ "locked" ];
    #       bind = {
    #         _args = [ "Ctrl m" ];
    #         SwitchToMode = "locked";
    #       };
    #     };
    #     locked = {
    #       bind = {
    #         _args = [ "Ctrl m" ];
    #         SwitchToMode = "normal";
    #       };
    #     };
    #   };
    # };
  };
  xdg.configFile."zellij".source = ../config/zellij;
  xdg.configFile."zellij/layouts/default.kdl".source = ../config/zellij/layouts/default.kdl;
}
