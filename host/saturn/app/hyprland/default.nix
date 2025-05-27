{...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1,2560x1440@180,0x0,1"
      "DP-2,2560x1440@144,2560x0,1"
    ];
    workspace = [
      "1,monitor:DP-1,default:true"
      "2,monitor:DP-1"
      "3,monitor:DP-1"
      "4,monitor:DP-1"
      "5,monitor:DP-1"
      "6,monitor:DP-1"
      "7,monitor:DP-1"

      "8,monitor:DP-2,default:true"
      "9,monitor:DP-2"
    ];
  };
}
