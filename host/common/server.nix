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

  programs.bash = {
    interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "24h";
  };

}
