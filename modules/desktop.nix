{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland";

  environment.systemPackages = with pkgs; [ vscode git alacritty firefox ];

  # System-wide programming and "ricing" fonts, including Nerd Font glyphs
  # used by terminals, Waybar, and other desktop components.
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.hack
  ];
}

# Prefer the installed Nerd Font variant whenever an application asks for a
# monospace face but does not set one explicitly.
