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
scripts/new-host.sh                scaffolds a new hosts/<name>/ folder ready
                                    for nixos-anywhere to install
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

## Setting up a new machine from this repo

Hosts are auto-discovered: any folder under `hosts/` with a
`configuration.nix` in it automatically becomes a
`nixosConfigurations.<folder-name>` — `flake.nix` never needs hand-editing
to add a machine. `home/joe.nix` is reused as-is by every host, no changes
needed there either.

Everything below runs **on the new machine itself** — no second computer
needed. If the installer complains about experimental features, add
`--extra-experimental-features 'nix-command flakes'` to the `nix` commands.

1. Boot the new machine from a NixOS installer USB and get it online
   (`nmtui` for WiFi, or just plug in ethernet).

2. Get this repo onto it. It's private, so from a bare installer use a
   **short-lived, fine-grained GitHub token** (Settings → Developer settings
   → Personal access tokens → fine-grained, scoped to this repo, read-only,
   expiring in a day — can be made from a phone):
   ```
   nix-shell -p git
   git clone https://<token>@github.com/joem04/nixos-config.git
   cd nixos-config
   ```
   Revoke the token afterwards. (Alternative: copy the repo onto the same
   USB stick beforehand and skip GitHub entirely.)

3. Scaffold the new host. This asks which disk to install to, confirming
   twice since it's destructive:
   ```
   scripts/new-host.sh <new-hostname>
   ```

4. Partition and mount the disk. This **erases it**:
   ```
   sudo nix run github:nix-community/disko -- \
     --mode destroy,format,mount hosts/<new-hostname>/disk-config.nix
   ```

5. Generate the real hardware config for this machine and put it in the
   repo, replacing the placeholder:
   ```
   sudo nixos-generate-config --no-filesystems --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix hosts/<new-hostname>/
   ```
   `--no-filesystems` matters: disko already defines the filesystems, so
   letting nixos-generate-config write its own would conflict.

6. Make the new files visible to Nix, then install:
   ```
   git add -A
   sudo nixos-install --root /mnt --flake .#<new-hostname>
   ```

7. Reboot. On the new machine:
   ```
   passwd    # replace the bootstrap password from modules/common.nix
   nmtui     # connect WiFi, if you're not on ethernet
   ```
   Your SSH key already works, since it's declared in `modules/common.nix`.

8. Commit and push the new host folder, **including the generated
   `hardware-configuration.nix`** — that file is what makes this machine
   reproducible from the repo in future.

### If you ever need a remote or headless install

The steps above assume you're sitting at the machine. For something with no
monitor attached — a NAS, a home server, a cloud box —
[nixos-anywhere](https://nix-community.github.io/nixos-anywhere/) does the
same job over SSH from another machine that has Nix, and never needs the
target to touch GitHub at all:
```
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config hosts/<name>/hardware-configuration.nix \
  --flake .#<name> \
  --target-host nixos@<target-ip>
```
The target must be booted into a NixOS installer (set a password with
`passwd` so it can SSH in) or be a Linux box it can `kexec`. Note it
[does not support WiFi](https://github.com/nix-community/nixos-anywhere#prerequisites)
on the kexec path — see limitations below.

### Cloning this repo without your usual GitHub keys

If you're setting up a new machine away from any device that already has
your GitHub SSH key (e.g. only the new laptop's live installer session is
available), use a **short-lived, fine-grained GitHub Personal Access
Token** instead: Settings → Developer settings → Personal access tokens →
Fine-grained token, scoped to just this repo, read-only, expiring in a day
or two (can be created from a phone browser).
```
git clone https://<token>@github.com/joem04/nixos-config.git
```
Revoke the token once you're done.

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

## Assumptions and limitations

Worth knowing before installing onto unfamiliar hardware:

- **UEFI only.** `modules/common.nix` uses systemd-boot and the disk layout
  creates an EFI system partition. A BIOS/legacy-boot-only machine will not
  boot this config without changes to both.
- **x86_64 only.** `flake.nix` hardcodes `system = "x86_64-linux"`. An
  ARM machine would need that made per-host.
- **Single disk.** The disko layout assumes one disk holding ESP + swap +
  root. Multi-disk, RAID, or LVM setups need a different `disk-config.nix`
  (see [disko's examples](https://github.com/nix-community/disko/tree/master/example)).
- **No hibernation.** Swap uses `randomEncryption`, so the key changes every
  boot and suspend-to-disk can't work. Remove it if you want hibernation.
- **Unencrypted root.** Only swap is encrypted. Fine for a home machine;
  add LUKS if the laptop travels with sensitive data.
- **No WiFi credentials in the config.** A freshly installed laptop with no
  ethernet has no network until you connect it with `nmtui` at the console.
  Declaring WiFi passwords would require real secrets management
  (sops-nix/agenix).
- **WiFi-only machines can't use the fully-unattended `kexec` path.**
  nixos-anywhere
  [does not support WiFi](https://github.com/nix-community/nixos-anywhere#prerequisites)
  when it has to `kexec` into its own installer: that image carries no WiFi
  credentials, so the network drops mid-install with the disk already wiped.
  This only affects machines with no ethernet (like `thinkpad`).
  **The normal new-machine flow is unaffected** — when you boot a NixOS
  installer USB yourself and connect WiFi with `nmtui`, nixos-anywhere
  detects the running installer, skips kexec entirely, and the connection
  survives. You just need physical access to start it off; the install
  itself still runs remotely from the control machine.
- **`--vm-test` uses a fixed 4 GiB virtual disk.** A layout needing more
  than that (this one needs 8.5 GiB for ESP + swap alone) fails with
  `Could not create partition`. disko's `imageSize` option does *not*
  override it. To smoke-test a layout in a VM, temporarily shrink the swap
  size; the structure is what's being validated, not the exact numbers.
- **`nixos-generate-config` vs `nixos-facter`.** This repo uses the former.
  [nixos-facter](https://github.com/nix-community/nixos-facter) produces a
  more detailed hardware report and can auto-configure drivers and firmware;
  worth considering if you start installing onto more varied hardware.
