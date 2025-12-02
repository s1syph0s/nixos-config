{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.me.niri;
in
{
  # This is included by config.kdl
  options.me.niri = {
    enable = lib.mkEnableOption "niri";
    profile = lib.mkOption {
      type = lib.types.path;
      default = ./default.kdl;
      apply = toString;
    };
    debug = lib.mkOption {
      type = lib.types.string;
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
    xdg.configFile."niri/profile.kdl".source = cfg.profile;
  };
}
