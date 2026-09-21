# nixos-config

Personal NixOS configuration, managed as code with [flakes](https://wiki.nixos.org/wiki/Flakes), [Home Manager](https://github.com/nix-community/home-manager), and [disko](https://github.com/nix-community/disko).

Everything a machine needs — packages, desktop, disk layout, dotfiles — lives in this repo. Clone it onto a new machine and get the same setup back, disk partitioning included.

## Structure

| Path | Purpose |
|---|---|
| `flake.nix` | Entry point. Auto-discovers every host under `hosts/` — never needs editing to add one. |
| `modules/` | Settings shared by every machine, split by topic. |
| `hosts/<name>/` | One folder per machine: hostname, hardware detection, disk layout. |
| `home/joe.nix` | Personal environment (Home Manager) — dotfiles, git identity, packages. |
| `scripts/new-host.sh` | Scaffolds a new host when installing on another machine. |

**`modules/`, by topic:**

| File | Contains |
|---|---|
| `default.nix` | Imports everything below — this is what each host actually imports. |
| `boot.nix` | Bootloader |
| `networking.nix` | NetworkManager, Avahi, SSH |
| `desktop.nix` | Xorg, i3, lightdm, system packages |
| `users.nix` | User account, bootstrap password, trusted SSH keys |
| `nix-settings.nix` | Flakes, unfree packages, passwordless sudo |

**Where do I add things?**

| Want to... | Edit |
|---|---|
| Add something for **every** machine | The relevant file in `modules/` |
| Add something for **one** machine only | `hosts/<name>/configuration.nix` |
| Add a personal dotfile, tool, or setting | `home/joe.nix` |

## Day-to-day

```sh
git add -A                          # only needed if you created new files
sudo nixos-rebuild switch           # apply the change
git commit -am "describe it" && git push
```

Something broke? `sudo nixos-rebuild switch --rollback`, or pick an older generation from the systemd-boot menu at startup.

## Setting up a new machine

Boot a NixOS installer USB on the new machine, run `scripts/new-host.sh`, then disko + `nixos-install`. Full walkthrough: **[docs/INSTALL.md](docs/INSTALL.md)**.

## Before you rely on this

Assumptions this config makes (UEFI, single disk, no WiFi secrets, and a few others worth knowing) and notes on the security tradeoffs it makes: **[docs/NOTES.md](docs/NOTES.md)**.
