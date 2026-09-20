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

### Option A: from a machine you already trust (e.g. WSL with Nix, or this ThinkPad)

1. Boot the new machine into any live Linux environment with SSH enabled
   (a NixOS installer image is fine), and note its IP address.
2. On your trusted machine: `git clone git@github.com:joem04/nixos-config.git`
3. Run `scripts/new-host.sh <new-hostname>` — it asks which disk to install
   to (with a confirmation, since this is destructive) and scaffolds
   `hosts/<new-hostname>/` for you.
4. Partition + install using
   [nixos-anywhere](https://github.com/nix-community/nixos-anywhere):
   ```
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#NEW-NAME root@<new-machine-ip>
   ```
   It partitions the disk, installs NixOS with your full config, and
   reboots into it automatically.
5. Commit the new host folder and push.

### Option B: with only the new laptop itself (no separate control machine)

You don't strictly need a second machine — the NixOS installer environment
you boot the new laptop into already has Nix, git, and everything else
needed. This works entirely from that one live session:

1. Boot the new laptop from a NixOS installer USB, connect to the internet.
2. Clone the repo. Since it's private and you likely won't have your usual
   SSH key on a live/borrowed environment, use a **short-lived, fine-grained
   GitHub Personal Access Token** instead (Settings → Developer settings →
   Personal access tokens → Fine-grained token, scoped to just this repo,
   read-only, expiring in a day or two — can be created from a phone):
   ```
   git clone https://<token>@github.com/joem04/nixos-config.git
   cd nixos-config
   ```
   Revoke the token once you're done.
3. `scripts/new-host.sh <new-hostname>` — asks which disk to use, scaffolds
   `hosts/<new-hostname>/` for you. Nothing here requires hand-editing Nix
   syntax.
4. Follow the exact next-steps it prints (partition with disko, generate
   the real hardware config, `git add -A`, then `nixos-install`).
5. Reboot into the new machine. Since SSH keys are declared in
   `modules/common.nix`, your usual key already works on it immediately —
   no manual key setup needed.
6. Once you're back on a machine with your normal GitHub access, push the
   new host folder so the repo reflects this machine too.

## Notes on this setup

- SSH into this machine uses key-based auth only (password login is
  disabled). Add more trusted keys to `~/.ssh/authorized_keys` as needed.
- `security.sudo.wheelNeedsPassword = false` (in `modules/common.nix`) is
  set for convenience since these are single-user personal machines.
  Reconsider this if that ever changes.
