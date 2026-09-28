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
          blue = "0xb7b4e8";
          magenta = "0xd9a8d4";
          cyan = "0x9ec8d7";
          white = "0x${theme.text}";
        };
        bright = {
          black = "0x${theme.muted}";
          red = "0xffb0c2";
          green = "0xc7edd2";
          yellow = "0xf9dba9";
          blue = "0xd2d0ff";
          magenta = "0xf0c7ec";
          cyan = "0xc2e9f5";
          white = "0xffffff";
        };
      };
    };
  };
}
