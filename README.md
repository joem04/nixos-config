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
6. It reboots into the new machine automatically. Since SSH keys are
   declared in `modules/common.nix`, your usual key already works on it
   immediately — no manual key setup needed.
7. Commit and push the new host folder.

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

- SSH into this machine uses key-based auth only (password login is
  disabled). Add more trusted keys to `~/.ssh/authorized_keys` as needed.
- `security.sudo.wheelNeedsPassword = false` (in `modules/common.nix`) is
  set for convenience since these are single-user personal machines.
  Reconsider this if that ever changes.
