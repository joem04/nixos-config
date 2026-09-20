# nixos-config

Personal NixOS configuration, managed with flakes. Currently covers one
machine (`thinkpad`), structured so more machines can be added later without
restructuring anything.

## Layout

```
flake.nix                          entry point; auto-discovers every machine
                                    from the hosts/ folder — never needs
                                    editing to add one
flake.lock                         pins exact dependency versions so builds
                                    are reproducible
modules/common.nix                 settings shared by every machine
                                    (packages, services, desktop, etc.)
hosts/thinkpad/configuration.nix   this machine's differences only:
                                    hostname + system.stateVersion
hosts/thinkpad/hardware-configuration.nix
                                    auto-generated hardware detection, do not
                                    hand-edit
hosts/thinkpad/disk-config.nix     declarative disk partitioning (disko),
                                    specific to this machine's disk
home/joe.nix                       personal user environment (Home Manager):
                                    dotfiles, git config, personal packages —
                                    shared by every machine you use as joe
scripts/new-host.sh                scaffolds a new hosts/<name>/ folder when
                                    installing on a new machine
```

**Where do I add things?**
- Something you want on **every** machine (a program, a service) →
  `modules/common.nix`.
- Something specific to **one** machine only (rare — e.g. a laptop-specific
  driver quirk) → that machine's `hosts/<name>/configuration.nix`.
- Something personal to your user account, independent of which machine
  you're on (git settings, shell config, personal CLI tools, editor config)
  → `home/joe.nix`.

## Day-to-day workflow

1. Edit files in `~/nixos-config`.
2. **If you created any _new_ files**, stage them first — Nix silently
   ignores files git doesn't know about, so a new module you forgot to add
   will look like it's having no effect:
   ```
   git add -A
   ```
3. Apply the change:
   ```
   sudo nixos-rebuild switch
   ```
   (`/etc/nixos` is a symlink to this folder, so plain `nixos-rebuild`
   commands work without needing `--flake` flags.)
4. If it works and you're happy with it, commit and push:
   ```
   cd ~/nixos-config
   git add -A
   git commit -m "describe your change"
   git push
   ```

If a rebuild goes wrong, you can always boot into the previous generation
from the systemd-boot menu at startup, or run:
```
sudo nixos-rebuild switch --rollback
```

## Installing on a new machine

Everything here runs **on the new machine itself**, from a NixOS installer
USB. Adding a machine to this repo means creating one folder under `hosts/`;
`flake.nix` picks it up automatically, and `home/joe.nix` is reused as-is.

### Before you start

- A **NixOS installer USB** (write the ISO with Rufus, Etcher, or `dd`).
- A way to **get this repo onto the machine**. It's private, so either:
  - a short-lived **fine-grained GitHub token** (Settings → Developer
    settings → Personal access tokens → fine-grained, scoped to this repo,
    read-only, expiring in a day — can be created from a phone), or
  - a **copy of the repo on the same USB stick**, avoiding GitHub entirely.
- The machine should be **UEFI** and **x86_64** (see limitations below).

### Steps

1. Boot the installer USB and get online — plug in ethernet, or for WiFi:
   ```
   sudo systemctl start wpa_supplicant   # only if nmtui finds no device
   nmtui
   ```

2. Get the repo onto the machine and enter it:
   ```
   nix-shell -p git
   git clone https://<token>@github.com/joem04/nixos-config.git
   cd nixos-config
   ```
   Revoke the token afterwards.

3. Find the disk you want to install to, by stable ID:
   ```
   ls -l /dev/disk/by-id/
   ```
   Pick the **whole-disk** entry, not a partition (nothing ending
   `-part1`, `-part2`, ...).

4. Scaffold the new host. This only writes config files — nothing is
   wiped yet. It asks for the disk and makes you confirm it twice:
   ```
   scripts/new-host.sh <new-hostname>
   ```

5. Partition, format and mount the disk. **This erases it:**
   ```
   sudo nix run github:nix-community/disko -- \
     --mode destroy,format,mount hosts/<new-hostname>/disk-config.nix
   ```

6. Generate this machine's hardware config, overwriting the placeholder:
   ```
   sudo nixos-generate-config --no-filesystems --show-hardware-config \
     > hosts/<new-hostname>/hardware-configuration.nix
   ```
   `--no-filesystems` matters: disko already declares the filesystems, and
   letting `nixos-generate-config` write its own would conflict with them.

7. Install. Nix ignores untracked files, so stage first:
   ```
   git add -A
   sudo nixos-install --root /mnt --flake .#<new-hostname>
   ```
   At the end it prompts you to set a **root password** — worth setting, as
   it gives you a console fallback if anything goes wrong with your user
   account. (Pass `--no-root-password` to skip.)

8. Reboot and remove the USB. Log in as `joe` with the bootstrap password
   from `modules/common.nix`, then immediately:
   ```
   passwd    # set your real password
   nmtui     # connect WiFi, if you're not on ethernet
   ```
   Your SSH key already works, since it's declared in `modules/common.nix`.

9. Commit and push the new host folder, **including the generated
   `hardware-configuration.nix`** — that file is what makes this machine
   reproducible from the repo in future:
   ```
   git add -A
   git commit -m "add <new-hostname>"
   git push
   ```

If the installer complains about experimental features, add
`--extra-experimental-features 'nix-command flakes'` to the `nix` commands.

## Assumptions and limitations

Worth knowing before installing onto unfamiliar hardware:

- **UEFI only.** `modules/common.nix` uses systemd-boot and the disk layout
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

## Notes on this setup

- SSH uses key-based auth only; password login over SSH is disabled. Trusted
  keys are declared in `modules/common.nix`, so every machine built from this
  repo trusts them from first boot. Revoke a device by deleting its line and
  rebuilding.
- `users.users.joe.initialPassword` in `modules/common.nix` is a bootstrap
  password used **only when an account is first created** on a new machine.
  It exists so a freshly installed laptop has a working console login;
  without it the only way in would be SSH, which means no way in at all if
  WiFi isn't up yet. **Change it with `passwd` immediately after first
  boot.** It's plaintext by choice (short-lived, private repo), but it is
  readable in the Nix store and persists in git history — switch to
  `initialHashedPassword` with a `mkpasswd -m sha-512` hash if this repo
  ever becomes public.
- `security.sudo.wheelNeedsPassword = false` is set for convenience since
  these are single-user personal machines. Reconsider if that changes.
- The disko `device` is a `/dev/disk/by-id/...` path rather than
  `/dev/sda`/`/dev/nvme0n1`. The running system mounts by partition label,
  so this path only matters during install — which is exactly when naming
  the wrong disk is unrecoverable.
