{ pkgs, ... }:

{
  imports = [
    ./desktop/hyprland.nix
    ./desktop/shell.nix
  ];

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

  home.packages = with pkgs; [
    wofi
    swaybg
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    pavucontrol
    playerctl
    brightnessctl
    networkmanagerapplet
    libnotify
  ];

  # Standard visible cursor theme for Wayland, GTK, and XWayland applications.
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Let Home Manager manage itself.
  programs.home-manager.enable = true;
}
