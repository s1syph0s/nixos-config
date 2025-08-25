{
  config,
  lib,
  pkgs,
  ...
}: {
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
