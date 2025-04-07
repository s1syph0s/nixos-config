{...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-3,2560x1440@180,0x0,1"
      "DP-1,2560x1440@144,2560x0,1"
      "HDMI-A-1,1920x1080@60,2560x0,1"
    ];
    workspace = [
      "1,monitor:DP-3,default:true"
      "2,monitor:DP-3"
      "3,monitor:DP-3"
      "4,monitor:DP-3"
      "5,monitor:DP-3"
      "6,monitor:DP-3"
      "7,monitor:DP-3"

      "8,monitor:DP-1,default:true"
      "9,monitor:DP-1"
    ];
  };
}
