{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  # A minimal console login replaces the graphical SDDM greeter. Tuigreet
  # authenticates through PAM, then launches the Nix-managed Hyprland session.
  services.displayManager.sddm.enable = false;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --greeting \"NIXOS // THINKPAD\" --cmd ${pkgs.hyprland}/bin/Hyprland --theme 'border=white;text=white;prompt=white;input=white;time=white;greeting=white;action=white;button=black;container=black'";
      user = "greeter";
    };
  };
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
