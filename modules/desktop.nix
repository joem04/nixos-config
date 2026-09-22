{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland";

  environment.systemPackages = with pkgs; [ vscode git alacritty firefox ];
}
