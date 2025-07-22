{
  config,
  pkgs,
  lib,
  ...
}: let
  util = import ./util.nix {};
in {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    client.enable = true;
    startWithUserSession = "graphical";
  };
  xdg.configFile."systemd/user/emacs.service.d/override.conf".text = ''
    [Service]
    Environment=XDG_SESSION_TYPE=wayland
  '';
}
