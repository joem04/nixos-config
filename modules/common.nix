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

    # Bootstrap password, applied ONLY when the account is first created on a
    # brand-new machine. Existing machines are unaffected, and `passwd`
    # changes always win afterwards (users.mutableUsers stays true).
    #
    # Without this, a freshly installed machine has NO console/display-manager
    # login at all — the only way in would be SSH, so if WiFi isn't up on
    # first boot you'd be locked out of your own laptop entirely.
    #
    # Deliberately plaintext: it's replaced with `passwd` within minutes of
    # first boot, so the exposure window is tiny. Be aware it is readable in
    # the Nix store and stays in this repo's git history permanently — don't
    # reuse it anywhere, and switch to initialHashedPassword (a `mkpasswd
    # -m sha-512` hash) if this repo ever goes public.
    initialPassword = "changeme";

    # Public keys only — never put a private key here. Add one entry per
    # trusted device, with a comment identifying what it is, so a lost/
    # compromised device can be revoked by deleting just its line.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMbUYkwEXx5ac3MaXaE4rIievAWDXx5uHGG/xOS+QyG opencode-thinkpad"
    ];
  };
}
