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

Because shared settings live in `modules/common.nix`, adding a new machine
that behaves the same as this one is mostly copy-and-adjust-the-hardware:

1. `cp -r hosts/thinkpad hosts/NEW-NAME`
2. On the new machine, regenerate the two hardware-specific files:
   - `nixos-generate-config --show-hardware-config > hosts/NEW-NAME/hardware-configuration.nix`
   - Edit `hosts/NEW-NAME/disk-config.nix` to match that machine's actual
     disk (check with `lsblk`) — don't reuse the old device name blindly,
     disko partitioning is destructive.
3. In `hosts/NEW-NAME/configuration.nix`, change `networking.hostName` and
   set `system.stateVersion` to whatever NixOS release you're installing
   with (not necessarily the same as thinkpad's).
4. Add a `nixosConfigurations.NEW-NAME` entry to `flake.nix`, copying the
   `thinkpad` block and pointing it at `hosts/NEW-NAME/configuration.nix`.
   Reuse `home/joe.nix` as-is — no changes needed there.
5. Install NixOS using this flake (see options below), then commit the new
   host folder and push.

### Option A: manual (NixOS installer USB)
Boot the NixOS installer, get networking working, clone this repo, run
disko against the new disk config, then
`nixos-install --flake .#NEW-NAME`.

### Option B: nixos-anywhere (faster, no manual installer steps)
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) can
partition and install NixOS on a brand-new machine remotely over SSH, using
this repo directly — no interactive installer needed. Once
`hosts/NEW-NAME` exists in this repo:

1. Boot the new machine into any live Linux environment with SSH enabled
   (a NixOS installer image is fine).
2. From a machine with Nix installed (e.g. this ThinkPad, or WSL with Nix):
   ```
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#NEW-NAME root@<new-machine-ip>
   ```
3. It partitions the disk, installs NixOS with your full config, and
   reboots into it — done.

## Notes on this setup

- SSH into this machine uses key-based auth only (password login is
  disabled). Add more trusted keys to `~/.ssh/authorized_keys` as needed.
- `security.sudo.wheelNeedsPassword = false` (in `modules/common.nix`) is
  set for convenience since these are single-user personal machines.
  Reconsider this if that ever changes.
