{ ... }:

let
  theme = import ./theme.nix;
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 8;
        margin-top = 8;
        margin-left = 12;
        margin-right = 12;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "pulseaudio" "network" "battery" "clock" "tray" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "?";
            default = "?";
          };
          all-outputs = true;
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 64;
          separate-outputs = true;
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "??  muted";
          format-icons = {
            default = [ "?" "?" "?" ];
          };
          on-click = "pavucontrol";
        };

        network = {
          format-wifi = "??  {signalStrength}%";
          format-ethernet = "??  connected";
          format-disconnected = "??  offline";
          tooltip-format = "{ifname}: {ipaddr}";
          on-click = "nm-connection-editor";
        };

        battery = {
          interval = 15;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "??  {capacity}%";
          format-plugged = "??  {capacity}%";
          format-icons = [ "??" "??" "??" "??" "??" ];
        };

        clock = {
          format = "??  {:%a, %d %b  %H:%M}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "${theme.font}";
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: #${theme.text};
      }

      #workspaces,
      #window,
      #pulseaudio,
      #network,
      #battery,
      #clock,
      #tray {
        background: rgba(43, 32, 41, 0.94);
        border: 1px solid rgba(242, 167, 187, 0.20);
        border-radius: 12px;
        padding: 0 12px;
      }

      #workspaces button {
        color: #${theme.muted};
        padding: 0 5px;
      }

      #workspaces button.active {
        color: #${theme.accent};
      }

      #workspaces button:hover {
        background: transparent;
        box-shadow: none;
        color: #${theme.text};
      }

      #window {
        color: #${theme.muted};
      }

      #clock {
        color: #${theme.accent};
        font-weight: 600;
      }

      #pulseaudio:hover,
      #network:hover,
      #battery:hover,
      #clock:hover {
        border-color: #${theme.accentStrong};
      }

      #battery.warning { color: #${theme.warning}; }
      #battery.critical { color: #${theme.accentStrong}; }
      #battery.charging { color: #${theme.success}; }
    '';
  };

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "overlay";
      font = "${theme.font} 10";
      width = 360;
      height = 140;
      margin = "16";
      padding = "14";
      border-size = 2;
      border-radius = 12;
      default-timeout = 6000;
      background-color = "#${theme.surface}";
      text-color = "#${theme.text}";
      border-color = "#${theme.accentStrong}";
      progress-color = "over #${theme.accentDim}";
      icons = true;
      max-visible = 3;
    };
  };

  xdg.configFile."wofi/config".text = ''
    show=drun
    width=620
    height=420
    prompt=Search
    allow_images=true
    image_size=28
    matching=fuzzy
    insensitive=true
    hide_scroll=true
  '';

  xdg.configFile."wofi/style.css".text = ''
    window {
      margin: 0;
      border: 2px solid #${theme.accentStrong};
      border-radius: 16px;
      background-color: #${theme.backgroundAlt};
      font-family: "${theme.font}";
      font-size: 13px;
    }
    #input {
      margin: 14px;
      padding: 10px 12px;
      border: none;
      border-radius: 10px;
      color: #${theme.text};
      background-color: #${theme.surface};
    }
    #inner-box { margin: 0 10px 10px; }
    #entry { padding: 10px 12px; border-radius: 9px; color: #${theme.text}; }
    #entry:selected { background-color: #${theme.accentDim}; color: #${theme.text}; }
    #text { margin-left: 10px; }
  '';
}
