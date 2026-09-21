# Installing on a new machine

Everything here runs **on the new machine itself**, from a NixOS installer
USB. Adding a machine to this repo means creating one folder under `hosts/`;
`flake.nix` picks it up automatically, and `home/joe.nix` is reused as-is.

## Before you start

- A **NixOS installer USB** (write the ISO with Rufus, Etcher, or `dd`).
- A way to **get this repo onto the machine**. It's private, so either:
  - a short-lived **fine-grained GitHub token** (Settings → Developer
    settings → Personal access tokens → fine-grained, scoped to this repo,
    read-only, expiring in a day — can be created from a phone), or
  - a **copy of the repo on the same USB stick**, avoiding GitHub entirely.
- The machine should be **UEFI** and **x86_64** (see [NOTES.md](NOTES.md)).

## Steps

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
   from `modules/users.nix`, then immediately:
   ```
   passwd    # set your real password
   nmtui     # connect WiFi, if you're not on ethernet
   ```
   Your SSH key already works, since it's declared in `modules/users.nix`.

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
