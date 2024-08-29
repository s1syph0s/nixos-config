{ config, pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      copy_command = "wl-copy";
      keybinds.shared_except = {
        _args = [ "locked" ];
        bind = {
          _args = [ "Alt g" ];
          SwitchToMode = "locked";
        };
      };
      keybinds.locked = {
        bind = {
          _args = [ "Alt g" ];
          SwitchToMode = "normal";
        };
      };
    };
  };
}
