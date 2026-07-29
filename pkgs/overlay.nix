{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  overlays = [
    (final: prev: {
      hypr-kblayout = prev.callPackage ./hypr-kblayout {};
      # openssh = super.openssh.overrideAttrs (old: {
      #   patches = (old.patches or []) ++ [../patch/openssh.patch];
      #   doCheck = false;
      # });
      zjstatus = inputs.zjstatus.packages.${final.system}.default;
      ashell = inputs.ashell.packages.${final.system}.default;
      # FIXME: Used only for patching niri
      libdisplay-info_0_3 = prev.libdisplay-info.overrideAttrs (_oldAttrs: {
        version = "0.3.0";
        src = prev.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "emersion";
          repo = "libdisplay-info";
          rev = "0.3.0";
          hash = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
        };
      });
    })
  ];
in {
  nixpkgs.overlays = overlays;
}
