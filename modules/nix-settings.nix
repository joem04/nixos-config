{ ... }:

# How Nix itself, and admin access, behave on this machine.
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Convenient for personal machines managed remotely/via automation.
  security.sudo.wheelNeedsPassword = false;
}
