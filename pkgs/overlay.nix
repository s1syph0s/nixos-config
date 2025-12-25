{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  overlays = [
    (self: super: {
      hypr-kblayout = super.callPackage ./hypr-kblayout { };
      # openssh = super.openssh.overrideAttrs (old: {
      #   patches = (old.patches or []) ++ [../patch/openssh.patch];
      #   doCheck = false;
      # });
      zjstatus = inputs.zjstatus.packages.${self.system}.default;
    })
  ];
in
{
  nixpkgs.overlays = overlays;
}
