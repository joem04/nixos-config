{ ... }:

let
  theme = import ./theme.nix;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.94;
        decorations = "None";
        dynamic_title = true;
        padding = {
          x = 12;
          y = 12;
        };
      };

      font = {
        normal = {
          family = "${theme.font} Mono";
          style = "Regular";
        };
        bold = {
          family = "${theme.font} Mono";
          style = "Bold";
        };
        italic = {
          family = "${theme.font} Mono";
          style = "Italic";
        };
        size = 11.5;
      };

      cursor = {
        style = "Beam";
        unfocused_hollow = true;
      };
      selection.save_to_clipboard = true;

      colors = {
        primary = {
          background = "0x${theme.background}";
          foreground = "0x${theme.text}";
        };
        cursor = {
          text = "0x${theme.background}";
          cursor = "0x${theme.accent}";
        };
        selection = {
          text = "0x${theme.text}";
          background = "0x${theme.accentDim}";
        };
        normal = {
          black = "0x${theme.backgroundAlt}";
          red = "0x${theme.accentStrong}";
          green = "0x${theme.success}";
          yellow = "0x${theme.warning}";
          blue = "0xc4c4c4";
          magenta = "0xcdcdcd";
          cyan = "0xc0c0c0";
          white = "0x${theme.text}";
        };
        bright = {
          black = "0x${theme.muted}";
          red = "0xf5f5f5";
          green = "0xe0e0e0";
          yellow = "0xe8e8e8";
          blue = "0xe5e5e5";
          magenta = "0xebebeb";
          cyan = "0xe2e2e2";
          white = "0xffffff";
        };
      };
    };
  };
}
