# nixos-config

Personal NixOS configuration, managed with flakes. Currently covers one
machine (`thinkpad`), structured so more machines can be added later without
restructuring anything.

## Layout

```
flake.nix                          entry point; lists all machines
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
2. Apply the change:
   ```
   sudo nixos-rebuild switch
   ```
   (`/etc/nixos` is a symlink to this folder, so plain `nixos-rebuild`
   commands work without needing `--flake` flags.)
3. If it works and you're happy with it, commit and push:
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

New machines are installed with
[nixos-anywhere](https://nix-community.github.io/nixos-anywhere/), following
its documented process exactly (see its
[quickstart](https://nix-community.github.io/nixos-anywhere/quickstart.html)
and
[no-OS how-to](https://nix-community.github.io/nixos-anywhere/howtos/no-os.html)).
nixos-anywhere runs from a **control machine** with Nix installed — this can
be a genuinely separate device (this ThinkPad, WSL, a cloud VM), or the
target's own live installer session targeting itself over `localhost` (SSH
doesn't care whether "remote" is a different physical machine — this pattern
is used in nixos-anywhere's own test suite). Either way, the steps are the
same:

1. Boot the target machine from a NixOS installer USB (or netboot),
   connect it to a network.
2. On the target's own console, set a password so nixos-anywhere can SSH in
   as the installer's default `nixos` user, and find its IP:
   ```
   passwd
   ip addr
   ```
3. On the control machine, clone this repo (see "cloning without your usual
   keys" below if you don't have your normal GitHub access on this machine),
   then run:
   ```
   scripts/new-host.sh <new-hostname>
   ```
   This asks which disk on the target to install to (confirming twice,
   since it's destructive) and scaffolds `hosts/<new-hostname>/` — this is
   the one piece nixos-anywhere genuinely requires you to supply yourself;
   it doesn't inspect the target's disks for you.
4. `git add -A` (so Nix can see the new files), then optionally test first:
   ```
   nix run github:nix-community/nixos-anywhere -- --flake .#<new-hostname> --vm-test
   ```
5. Install for real. This single command partitions the disk, generates the
   real hardware config, and installs NixOS — all remotely, unattended:
   ```
   nix run github:nix-community/nixos-anywhere -- \
     --generate-hardware-config nixos-generate-config hosts/<new-hostname>/hardware-configuration.nix \
     --flake .#<new-hostname> \
     --target-host nixos@<target-ip>
   ```
6. It reboots into the new machine automatically. On that machine:
   ```
   passwd    # replace the bootstrap password from modules/common.nix
   nmtui     # connect WiFi, if you're not on ethernet
   ```
   Your SSH key already works too, since it's declared in
   `modules/common.nix` — no manual key setup needed.
7. Commit and push the new host folder, **including the
   `hardware-configuration.nix` that nixos-anywhere generated** — that file
   is what makes the machine reproducible from the repo in future.

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
- **`nixos-generate-config` vs `nixos-facter`.** This repo uses the former.
  [nixos-facter](https://github.com/nix-community/nixos-facter) produces a
  more detailed hardware report and can auto-configure drivers and firmware;
  worth considering if you start installing onto more varied hardware.
