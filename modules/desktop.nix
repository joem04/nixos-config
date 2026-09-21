{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "none+i3";

  environment.systemPackages = with pkgs; [ vscode git alacritty dmenu firefox ];
}
