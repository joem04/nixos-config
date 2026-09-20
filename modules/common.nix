{ config, lib, pkgs, ... }:

# Settings shared by every machine. Machine-specific files (in hosts/<name>/)
# should only contain things that genuinely differ per machine: hostname,
# hardware detection, disk layout, and system.stateVersion.
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Convenient for personal machines managed remotely/via automation.
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = { PasswordAuthentication = false; PermitRootLogin = "no"; };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
  };

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "none+i3";

  environment.systemPackages = with pkgs; [ vscode git alacritty dmenu firefox ];

  users.users.joe = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    # Public keys only — never put a private key here. Add one entry per
    # trusted device, with a comment identifying what it is, so a lost/
    # compromised device can be revoked by deleting just its line.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMbUYkwEXx5ac3MaXaE4rIievAWDXx5uHGG/xOS+QyG opencode-thinkpad"
    ];
  };
}
