{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1,2560x1440@144,0x180,1"
      "HDMI-A-1,1920x1080@60,2560x0,1,transform,3"
    ];
    workspace = [
      "1,monitor:DP-1,default:true"
      "2,monitor:DP-1"
      "3,monitor:DP-1"
      "4,monitor:DP-1"
      "5,monitor:DP-1"
      "6,monitor:DP-1"
      "7,monitor:DP-1"

      "8,monitor:HDMI-A-1,default:true"
      "9,monitor:HDMI-A-1"
    ];
  };
}
