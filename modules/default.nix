{ ... }:

# Settings shared by every machine, split by topic. Machine-specific files
# (in hosts/<name>/) should only contain things that genuinely differ per
# machine: hostname, hardware detection, disk layout, and system.stateVersion.
{
  imports = [
    ./boot.nix
    ./networking.nix
    ./desktop.nix
    ./users.nix
    ./nix-settings.nix
  ];
}
