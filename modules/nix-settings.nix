{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  security.sudo.wheelNeedsPassword = false;
}
