{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    fishPlugins.pure
    fishPlugins.fzf
  ];
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # pure cfg
      set -U pure_enable_nixdevshell true
      set -U pure_show_subsecond_command_duration true
    '';
  };
}
