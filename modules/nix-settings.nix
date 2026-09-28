{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Deduplicate identical store files as paths are added to the store.
    auto-optimise-store = true;
  };

  # Keep the store from growing indefinitely while preserving recent rollbacks.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo.wheelNeedsPassword = false;
}
