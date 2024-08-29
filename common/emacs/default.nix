{ config, pkgs, ... }:

let
  util = import ./util.nix {};
in 
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
  };
}
