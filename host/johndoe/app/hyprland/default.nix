{...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = "eDP-1,1920x1080@60,0x0,1";
    input.touchpad = {
      natural_scroll = true;
      middle_button_emulation = true;
      clickfinger_behavior = true;
    };
  };
}
