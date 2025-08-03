{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.loader.grub.enable = true;
  services.openssh.enable = true;

  users.users.root = {
    initialHashedPassword = "$y$j9T$TiPYI3DDO0wYPv0jaOGhQ0$/DTwieWqqKA4.xtLKDiKQOTKtYdvzxfyaRLTN2SVeqB";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPdOPyuU3TFfLU7fwjjaf3X8peBiTQAaX6pN8XfIkKW terabithia"
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  system.stateVersion = "25.05";
}
