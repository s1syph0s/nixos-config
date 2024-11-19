{ config, nixpkgs, ... }:

{
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      #"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "dbus-update-activation-environment --systemd --all"
      "waybar" 
      "nm-applet --indicator"
      "swaybg -m fill -i ~/media/img/wallpaper-moebius.png"
      "mako"
      "swayidle -w timeout 300 'swaylock -f -c 000000' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f -c 000000' & disown"
    ];
    env = [
      "HYPRCURSOR_TYPE,Capitaine Cursors (Nord)"
      "HYPRCURSOR_SIZE,32"
      "XCURSOR_TYPE,Capitaine Cursors (Nord)"
      "XCURSOR_SIZE,32"
    ];
    input = {
      kb_layout = "us,de";
      kb_variant = ",nodeadkeys";
      kb_options = "grp:alt_shift_toggle,ctrl:nocaps";
      numlock_by_default = true;
      follow_mouse = 1;
      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };
    general = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "rgba(dfcacbee) rgba(6a7997ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      layout = "dwindle";
    };
    decoration = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      rounding = 8;
      
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      
      blur = {
          enabled = true;
          size = 3;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
      };

      shadow = {
        enabled = true;
        color = "rgba(1a1a1aee)";
      };
    };
    animations = {
      enabled = true;

      # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

      animation = [
        "windows, 1, 5, myBezier"
        "windowsOut, 1, 5, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 5, default"
        "specialWorkspace, 1, 5, myBezier, slidevert"
      ];
    };

    dwindle = {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = true; # you probably want this
    };

    gestures.workspace_swipe = false;
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      mouse_move_enables_dpms = true;
      enable_swallow = true;
      vrr = 2;
      swallow_regex = "^(alacritty)$";
    };

    windowrulev2 = [
      "float,class:^(steam)$,title:^(Friends List)$"
    ];

    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, RETURN, exec, alacritty"
      "$mainMod + Shift, Q, killactive, "
      "$mainMod + Shift, E, exit, "
      "$mainMod, E, exec, dolphin"
      "$mainMod, V, togglefloating, "
      "$mainMod, SPACE, exec, pkill anyrun || anyrun"
      "$mainMod, P, pseudo," # dwindle
      "$mainMod, B, togglesplit," # dwindle

      # Focus
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      "$mainMod, H, movefocus, l"
      "$mainMod, J, movefocus, d"
      "$mainMod, K, movefocus, u"
      "$mainMod, L, movefocus, l"

      # Fullscreen
      ", F11, fullscreen, 0"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"

      # Screenshot
      '', Print, exec, grim -g "$(slurp -d)" ~/media/img/screenshots/$(date +'screenshot_%d-%m-%Y-%H%M%S.png')''
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindle = [
      '', XF86AudioRaiseVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 5%+''
      '', XF86AudioRaiseVolume, exec, wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' > $WOBSOCK''
      '', XF86AudioLowerVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 5%-''
      '', XF86AudioLowerVolume, exec, wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' > $WOBSOCK''
    ];

    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMute, exec, wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if ($3) print 0; else print int($2*100)}' > $WOBSOCK"
    ];
  };
}
