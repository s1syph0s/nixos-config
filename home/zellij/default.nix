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
  xdg.configFile."zellij".source = ../config/zellij;
  xdg.configFile."zellij/layouts/default.kdl".source = ../config/zellij/layouts/default.kdl;
}
