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

      # FIXME: remove after NixOS/nixpkgs#568692 is fixed
      # inherit (inputs.nixpkgs-zotero.legacyPackages.${final.stdenv.hostPlatform.system}) zotero;
    })
  ];
in {
  nixpkgs.overlays = overlays;
}
