#!/usr/bin/env bash
# Scaffold a new host, ready to install with nixos-anywhere.
#
# Run this on any machine with Nix — it does NOT need to be the target
# machine. See https://nix-community.github.io/nixos-anywhere/quickstart.html
#
# Usage: scripts/new-host.sh <new-hostname>
#
# Per nixos-anywhere's documented process, this script only does the things
# that are genuinely manual and NOT automated by nixos-anywhere itself:
#   - Recording which disk on the target to install to (quickstart step 4:
#     you identify the disk yourself and put it in disk-config.nix —
#     nixos-anywhere never inspects the target's disks for you)
#   - Creating a placeholder hardware-configuration.nix so the flake can
#     evaluate (quickstart step 8: the import must already exist;
#     nixos-anywhere then writes the REAL contents during install via
#     --generate-hardware-config)
#
# It deliberately does NOT run disko, generate a real hardware config, or run
# nixos-install — nixos-anywhere does all three itself, remotely, in the one
# command printed at the end.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <new-hostname>" >&2
  exit 1
fi

HOST="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/hosts/thinkpad"
HOST_DIR="$REPO_ROOT/hosts/$HOST"

if [ -e "$HOST_DIR" ]; then
  echo "hosts/$HOST already exists — pick a different name, or remove it first." >&2
  exit 1
fi

cat <<'PROMPT'
On the TARGET machine (booted from a NixOS installer USB), list its disks by
stable ID:

    ls -l /dev/disk/by-id/

Pick the whole-disk entry for the drive you want to install to — NOT a
partition (ignore anything ending in -part1, -part2, ...). It will look
something like:

    nvme-SAMSUNG_MZVL2512HCJQ_S64KNX0T123456
    ata-Samsung_SSD_870_EVO_500GB_S6PENL0T900001

Using the by-id name rather than /dev/sda or /dev/nvme0n1 matters here:
this is the disk that gets WIPED, and kernel names can shift between boots.

PROMPT

read -rp "Target disk by-id name: " DISK_ID

if [ -z "$DISK_ID" ]; then
  echo "No disk given — aborting, nothing was changed." >&2
  exit 1
fi

case "$DISK_ID" in
  *-part[0-9]*)
    echo "That looks like a partition, not a whole disk — aborting." >&2
    exit 1
    ;;
  /dev/*)
    echo "Enter just the by-id name, without the /dev/disk/by-id/ prefix." >&2
    exit 1
    ;;
esac

DISK_PATH="/dev/disk/by-id/$DISK_ID"

echo
echo "!! nixos-anywhere will DESTROY ALL DATA on $DISK_PATH on the target. !!"
read -rp "Type the disk name again to confirm: " CONFIRM
if [ "$CONFIRM" != "$DISK_ID" ]; then
  echo "Confirmation did not match — aborting, nothing was changed." >&2
  exit 1
fi

mkdir -p "$HOST_DIR"
cp "$TEMPLATE_DIR/configuration.nix" "$HOST_DIR/configuration.nix"
cp "$TEMPLATE_DIR/disk-config.nix" "$HOST_DIR/disk-config.nix"

sed -i "s/networking.hostName = \"[^\"]*\";/networking.hostName = \"$HOST\";/" "$HOST_DIR/configuration.nix"
sed -i "s#device = \"[^\"]*\";#device = \"$DISK_PATH\";#" "$HOST_DIR/disk-config.nix"

# system.stateVersion is intentionally inherited from the template: it should
# match the nixpkgs release this flake installs (nixos-26.05), not whatever
# release the machine running this script happens to be on.

cat > "$HOST_DIR/hardware-configuration.nix" <<'EOF'
# Placeholder — nixos-anywhere overwrites this during install via its
# --generate-hardware-config flag. Do not fill it in by hand.
#
# It must exist (and be git-tracked) before installing, because the flake
# imports it, and Nix only sees files git knows about.
{ }
EOF

cat <<EOF

Created hosts/$HOST (hostname + target disk recorded).

Next steps — see https://nix-community.github.io/nixos-anywhere/quickstart.html

  1. Boot the target from a NixOS installer USB and get it onto the network
     (WiFi is fine via 'nmtui' — no kexec happens when an installer is
     already running, so WiFi is not a problem in this flow).

  2. On the target's own console, set a password so nixos-anywhere can SSH
     in as the installer's default 'nixos' user, and find its IP:
       passwd
       ip addr

  3. Make the new files visible to Nix (Nix ignores untracked files):
       git -C "$REPO_ROOT" add -A

  4. (Optional) smoke-test the layout in a VM. NOTE: --vm-test uses a fixed
     4GiB virtual disk, so it will FAIL on this layout as-is (512M ESP + 8G
     swap needs 8.5GiB). To try it, temporarily shrink swap in
     hosts/$HOST/disk-config.nix, run the test, then change it back:
       nix run github:nix-community/nixos-anywhere -- \\
         --flake "$REPO_ROOT#$HOST" --vm-test

  5. Install. This single command partitions the disk, generates the real
     hardware config, and installs NixOS — all remotely:
       nix run github:nix-community/nixos-anywhere -- \\
         --generate-hardware-config nixos-generate-config "$HOST_DIR/hardware-configuration.nix" \\
         --flake "$REPO_ROOT#$HOST" \\
         --target-host nixos@<target-ip>

  6. It reboots into the new system. Log in at the console with the
     bootstrap password from modules/common.nix, then:
       passwd                 # set your real password
       nmtui                  # connect WiFi, if not on ethernet

  7. Commit and push the new host folder (including the generated
     hardware-configuration.nix).
EOF
