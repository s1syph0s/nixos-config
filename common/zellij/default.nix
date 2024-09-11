{ config, pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      copy_command = "wl-copy";
      keybinds.shared_except = {
        _args = [ "locked" ];
      };
    };
  };
}
