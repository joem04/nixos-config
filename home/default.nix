{ pkgs, lib, ... }:

{
  home.username = "joe";
  home.homeDirectory = "/home/joe";
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Joe M";
      email = "30784663+joem04@users.noreply.github.com";
    };
  };

  programs.bash.enable = true;
  home.packages = with pkgs; [ wofi ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # mkDefault so a per-host override (see home/hosts/<name>.nix) fully
      # replaces this instead of Nix concatenating both lists together.
      monitor = lib.mkDefault [ ",preferred,auto,1" ];
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod, D, exec, wofi --show drun"
        "$mod SHIFT, E, exit"
      ];
      exec-once = [ "waybar" ];
    };
  };

  programs.waybar.enable = true;

  # Let Home Manager manage itself.
  programs.home-manager.enable = true;
}
