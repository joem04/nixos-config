{ config, lib, ... }:

let
  theme = import ./theme.nix;
  wallpaper = "${config.home.homeDirectory}/.local/share/wallpapers/lightcrimson.svg";
in
{
  home.file.".local/share/wallpapers/lightcrimson.svg".source = ./lightcrimson.svg;
  home.file.".local/bin/close-active-window" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      if hyprctl activewindow | grep -qi "class: vesktop"; then
        pkill -x vesktop
      else
        hyprctl dispatch killactive
      fi
    '';
  };


  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";

    settings = {
      monitor = lib.mkDefault [ ",preferred,auto,1" ];
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "wofi --show drun";

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "rgb(${theme.accentStrong})";
        "col.inactive_border" = "rgb(${theme.surfaceBright})";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 12;
        active_opacity = 1.0;
        inactive_opacity = 0.94;
        blur = {
          enabled = true;
          size = 5;
          passes = 2;
          xray = true;
        };
        shadow = {
          enabled = true;
          range = 16;
          render_power = 3;
          color = "rgb(${theme.background})";
        };
      };

      animations = {
        enabled = true;
        bezier = [ "snappy, 0.22, 1, 0.36, 1" ];
        animation = [
          "windows, 1, 5, snappy"
          "windowsOut, 1, 4, default, popin 82%"
          "border, 1, 5, default"
          "fade, 1, 4, default"
          "workspaces, 1, 4, default, slide"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          drag_lock = true;
        };
      };

      dwindle = {
        preserve_split = true;
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };

      windowrule = [
        "float on, match:class ^(pavucontrol)$"
        "size 900 600, match:class ^(pavucontrol)$"
        "float on, match:class ^(nm-connection-editor)$"
        "size 900 600, match:class ^(nm-connection-editor)$"
        "float on, match:title ^(Open File|Save File|Choose File)$"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, SPACE, exec, $menu"
        "$mod, B, exec, firefox"
        "$mod, Q, exec, ${config.home.homeDirectory}/.local/bin/close-active-window"
        "$mod SHIFT, E, exit,"
        "$mod, F, fullscreen, 0"
        "$mod, V, togglefloating,"
        "$mod, P, pseudo,"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ] ++ (builtins.concatLists (builtins.genList (x:
        let workspace = toString (x + 1); in [
          "$mod, ${workspace}, workspace, ${workspace}"
          "$mod SHIFT, ${workspace}, movetoworkspace, ${workspace}"
        ]) 9));

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      exec-once = [
        "swaybg -i ${wallpaper} -m fill"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "waybar"
      ];
    };
  };
}
