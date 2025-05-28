{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "fistanto";
  home.homeDirectory = "/home/fistanto";

  fonts.fontconfig.enable = true;

  imports = [
    ../../home
    ./app/hyprland
  ];
  _module.args = {inherit inputs;};
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/fistanto/.dotfiles";
  };
  services.blueman-applet.enable = true;
}
