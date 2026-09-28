{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  # Keep a bounded set of known-good generations for rollback.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
}
