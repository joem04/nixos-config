# Assumptions and limitations

Worth knowing before installing onto unfamiliar hardware:

- **UEFI only.** `modules/boot.nix` uses systemd-boot and the disk layout
  creates an EFI system partition. A BIOS/legacy-boot-only machine will not
  boot this config without changes to both.
- **x86_64 only.** `flake.nix` hardcodes `system = "x86_64-linux"`. An ARM
  machine would need that made per-host.
- **Single disk.** The disko layout assumes one disk holding ESP + swap +
  root. Multi-disk, RAID, or LVM setups need a different `disk-config.nix`
  (see [disko's examples](https://github.com/nix-community/disko/tree/master/example)).
- **No hibernation.** Swap uses `randomEncryption`, so the key changes every
  boot and suspend-to-disk can't work. Remove it if you want hibernation.
- **Unencrypted root.** Only swap is encrypted. Fine for a home machine;
  add LUKS if the laptop travels with sensitive data.
- **No WiFi credentials in the config.** A freshly installed laptop with no
  ethernet has no network until you connect it with `nmtui` at the console.
  Declaring WiFi passwords would need real secrets management
  (sops-nix/agenix).

# Notes on this setup

- SSH uses key-based auth only; password login over SSH is disabled. Trusted
  keys are declared in `modules/users.nix`, so every machine built from this
  repo trusts them from first boot. Revoke a device by deleting its line and
  rebuilding.
- `users.users.joe.initialPassword` in `modules/users.nix` is a bootstrap
  password used **only when an account is first created** on a new machine.
  It exists so a freshly installed laptop has a working console login;
  without it the only way in would be SSH, which means no way in at all if
  WiFi isn't up yet. **Change it with `passwd` immediately after first
  boot.**
  This repo is public, so that password is visible to anyone — a deliberate
  choice, not an oversight: it's only ever valid for the few minutes before
  you run `passwd`, and SSH password auth is already disabled, so it isn't
  remotely exploitable. If that tradeoff ever stops being acceptable, switch
  to `initialHashedPassword` with a `mkpasswd -m sha-512` hash instead.
- This repo also publishes `hosts/thinkpad/disk-config.nix`, which includes
  the exact model and serial number of that machine's SSD. Also accepted
  knowingly — low risk, but worth knowing it's public.
- `security.sudo.wheelNeedsPassword = false` (in `modules/nix-settings.nix`)
  is set for convenience since these are single-user personal machines.
  Reconsider if that changes.
- The disko `device` is a `/dev/disk/by-id/...` path rather than
  `/dev/sda`/`/dev/nvme0n1`. The running system mounts by partition label,
  so this path only matters during install — which is exactly when naming
  the wrong disk is unrecoverable.
