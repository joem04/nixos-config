{ pkgs, ... }:

let
  theme = import ./theme.nix;
in
{
  # Compact, polished tools for an ergonomic terminal workflow.
  home.packages = with pkgs; [
    fastfetch
    btop
    eza
    zoxide
    bat
    fzf
    ripgrep
    fd
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.93;
        decorations = "None";
        dynamic_title = true;
        dynamic_padding = true;
        padding = {
          x = 18;
          y = 16;
        };
      };

      font = {
        normal = {
          family = "Iosevka Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "Iosevka Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "Iosevka Nerd Font Mono";
          style = "Italic";
        };
        size = 13.0;
        offset = {
          x = 0;
          y = 1;
        };
      };

      cursor = {
        style = "Beam";
        unfocused_hollow = true;
      };
      mouse.hide_when_typing = true;
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

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      format = "$username$hostname $directory$git_branch$git_status $character";
      username = {
        show_always = true;
        style_user = "bold white";
        format = "[$user]($style)";
      };
      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style)";
      };

      directory = {
        truncation_length = 3;
        truncation_symbol = ".../";
      };
      git_branch = {
        symbol = "git:";
        format = " [$symbol$branch]($style)";
        style = "white";
      };
      git_status = {
        format = " [$all_status$ahead_behind]($style)";
        style = "bright-black";
      };
      character = {
        success_symbol = "[>](bold white)";
        error_symbol = "[>](bold bright-black)";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    shellAliases = {
      ls = "eza --icons=auto";
      ll = "eza --icons=auto -lah --group-directories-first";
      la = "eza --icons=auto -a";
      tree = "eza --icons=auto --tree";
      cat = "bat --paging=never";
      find = "fd";
    };
  };
}
