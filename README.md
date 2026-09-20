# nixos-config

Personal NixOS configuration, managed with flakes. Currently covers one
machine (`thinkpad`), structured so more machines can be added later without
restructuring anything.

## Layout

```
flake.nix                          entry point; lists all machines
hosts/thinkpad/configuration.nix   this machine's system config (packages,
                                    services, desktop, etc.)
hosts/thinkpad/hardware-configuration.nix
                                    auto-generated hardware detection, do not
                                    hand-edit
hosts/thinkpad/disk-config.nix     declarative disk partitioning (disko)
home/joe.nix                       personal user environment (Home Manager):
                                    dotfiles, git config, personal packages
```

**Where do I add things?**
- A program/tool everyone on the machine should have, or a system service
  (like Bluetooth, Docker, etc.) → `hosts/thinkpad/configuration.nix`.
- Something personal to your user account (git settings, shell config,
  personal CLI tools, editor config) → `home/joe.nix`.

## Day-to-day workflow

1. Edit files in `~/nixos-config`.
2. Apply the change:
   ```
   sudo nixos-rebuild switch --flake ~/nixos-config#thinkpad
   ```
   (Since `/etc/nixos` is a symlink to this folder, plain
   `sudo nixos-rebuild switch` also works.)
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

### Option A: manual (NixOS installer USB)
1. Boot the NixOS installer, get networking working.
2. Clone this repo somewhere, e.g. `git clone git@github.com:joem04/nixos-config.git`.
3. `cp -r nixos-config/hosts/thinkpad nixos-config/hosts/NEW-NAME`, then edit
   `disk-config.nix` for the new machine's disk (check the device name with
   `lsblk`), and regenerate `hardware-configuration.nix` with
   `nixos-generate-config --show-hardware-config > hosts/NEW-NAME/hardware-configuration.nix`
   (after mounting the target disks per your disko config).
4. Add a `nixosConfigurations.NEW-NAME` entry to `flake.nix` (copy the
   `thinkpad` block and change the host path).
5. Run disko against the new disk config, then
   `nixos-install --flake .#NEW-NAME`.
6. Commit the new host folder and push.

### Option B: nixos-anywhere (faster, no manual installer steps)
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) can
partition and install NixOS on a brand-new machine remotely over SSH, using
this repo directly — no interactive installer needed. Rough steps once a
`hosts/NEW-NAME` entry exists in this repo (with a correct `disk-config.nix`
for the new hardware):

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
- `security.sudo.wheelNeedsPassword = false` is set for convenience since
  this is a single-user personal machine. Reconsider this if that ever
  changes.
