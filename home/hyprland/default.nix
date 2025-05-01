{
  config,
  nixpkgs,
  ...
}: {
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "waybar"
      "nm-applet --indicator"
      "swaybg -m fill -i ~/media/img/wallpaper-moebius.png"
      "mako"
      "hyprctl setcursor 'Capitaine Cursors (Nord)' 24"
      "dconf write /org/gnome/desktop/interface/cursor-theme \"'Capitaine Cursors (Nord)'\""
      "dconf write /org/gnome/desktop/interface/cursor-size 24"
    ];
    env = [
      "XCURSOR_TYPE,Capitaine Cursors (Nord)"
      "XCURSOR_SIZE,24"
      "XDG_SESSION_DESKTOP,Hyprland"
    ];
    input = {
      kb_layout = "us,de";
      kb_variant = ",nodeadkeys";
      kb_options = "grp:switch";
      numlock_by_default = true;
      follow_mouse = 1;
      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };
    general = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 0;
      gaps_out = 0;
      border_size = 2;
      # "col.active_border" = "rgba(dfcacbee) rgba(6a7997ee) 45deg";
      # "col.inactive_border" = "rgba(595959aa)";

      layout = "dwindle";
      allow_tearing = true;
    };
    group = {
      "col.border_active" = "rgba(313a4fee)";
      "col.border_inactive" = "rgba(151922ee)";
      groupbar = {
        text_color = "rgba(fefefeff)";
        font_family = "JetBrainsMono Nerd Font";
        gradients = true;
        "col.active" = "rgba(7e869eff)";
        "col.inactive" = "rgba(1e1d20ff)";
        gaps_in = 0;
        gaps_out = 0;
      };
    };
    decoration = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      rounding = 0;

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

      bezier = "myBezier, 0.1, 0.9, 0.1, 1.05";

      animation = [
        "windows, 1, 5, myBezier, slide"
        "windowsOut, 1, 5, myBezier, slide"
        "border, 1, 10, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
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
      vrr = 2;
      enable_swallow = true;
      swallow_regex = "^(com.mitchellh.ghostty|alacritty)$";
    };

    workspace = [
      "w[tv1], gapsout:0, gapsin:0"
      "w[tgv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];

    windowrule = [
      "float, class:^(steam)$, title:^(Friends List)$"
      "float, class:^(firefox)$, title:^(Picture-in-Picture)$"
      "workspace 1, class:^(emacs)$"
      "workspace 2, class:^(firefox)$"
      "workspace 3, class:^(steam)$"
      "workspace 8, class:^(vesktop)$"
      "rounding 8, floating:1"

      # smart window
      "bordersize 0, floating:0, onworkspace:w[tv1]"
      "rounding 0, floating:0, onworkspace:w[tv1]"
      "bordersize 0, floating:0, onworkspace:w[tgv1]"
      "rounding 0, floating:0, onworkspace:w[tgv1]"
      "bordersize 0, floating:0, onworkspace:f[1]"
      "rounding 0, floating:0, onworkspace:f[1]"
    ];

    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, RETURN, exec, alacritty"
      "$mainMod + Shift, Q, killactive, "
      "$mainMod + Shift, E, exit, "
      "$mainMod, E, exec, thunar"
      "$mainMod, V, togglefloating, "
      "$mainMod, SPACE, exec, pkill anyrun || anyrun"
      "$mainMod, P, pseudo," # dwindle
      "$mainMod, B, togglesplit," # dwindle
      "$mainMod, code:49, exec, hyprlock" # WIN + `

      # Focus
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      "$mainMod, H, movefocus, l"
      "$mainMod, J, movefocus, d"
      "$mainMod, K, movefocus, u"
      "$mainMod, L, movefocus, r"

      # Fullscreen
      ", F11, fullscreen, 0"

      # Tab
      "$mainMod, t, togglegroup"
      "$mainMod, b, changegroupactive, b"
      "$mainMod, f, changegroupactive, f"
      "$mainMod CTRL, H, changegroupactive, b"
      "$mainMod CTRL, L, changegroupactive, f"

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

      # Move focus to monitor
      "$mainMod SHIFT, H, focusmonitor, -1"
      "$mainMod SHIFT, L, focusmonitor, +1"

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
