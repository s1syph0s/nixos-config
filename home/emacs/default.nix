{
  config,
  pkgs,
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
}
