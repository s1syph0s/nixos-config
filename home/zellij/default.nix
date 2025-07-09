{
  config,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };
  xdg.configFile."zellij" = {
    source = ./config;
    recursive = true;
  };
}
