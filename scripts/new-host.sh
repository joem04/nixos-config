#!/usr/bin/env bash
# Scaffold a new host from inside a NixOS live installer environment.
# Run this from the root of a cloned copy of this repo.
#
# Usage: scripts/new-host.sh <new-hostname>
#
# What it does:
#   - Copies hosts/thinkpad as a template into hosts/<new-hostname>
#   - Asks which disk to install to (with a confirmation, since this is
#     later used by disko to WIPE that disk)
#   - Fills in the hostname and NixOS version automatically
#   - Leaves hardware-configuration.nix as a placeholder — that one can only
#     be generated for real after disko has partitioned and mounted the disk
#     (see the printed next steps at the end)
#
# It does NOT touch flake.nix — hosts are auto-discovered from the hosts/
# folder, so nothing there needs editing.

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

echo "== Available disks =="
lsblk -d -o NAME,SIZE,MODEL
echo

read -rp "Which disk should NixOS be installed on? (name only, e.g. nvme0n1): " DISK
DISK_PATH="/dev/$DISK"

if [ ! -b "$DISK_PATH" ]; then
  echo "No such block device: $DISK_PATH" >&2
  exit 1
fi

echo
echo "!! Running disko against $DISK_PATH later will DESTROY ALL DATA on it. !!"
read -rp "Type the disk name again to confirm ($DISK): " CONFIRM
if [ "$CONFIRM" != "$DISK" ]; then
  echo "Confirmation did not match — aborting, nothing was changed." >&2
  exit 1
fi

mkdir -p "$HOST_DIR"
cp "$TEMPLATE_DIR/configuration.nix" "$HOST_DIR/configuration.nix"
cp "$TEMPLATE_DIR/disk-config.nix" "$HOST_DIR/disk-config.nix"

sed -i "s/networking.hostName = \"[^\"]*\";/networking.hostName = \"$HOST\";/" "$HOST_DIR/configuration.nix"

NIXOS_VERSION="$(nixos-version | cut -d. -f1-2)"
sed -i "s/system.stateVersion = \"[^\"]*\";/system.stateVersion = \"$NIXOS_VERSION\";/" "$HOST_DIR/configuration.nix"

sed -i "s#device = \"[^\"]*\";#device = \"$DISK_PATH\";#" "$HOST_DIR/disk-config.nix"

cat > "$HOST_DIR/hardware-configuration.nix" <<'EOF'
# Placeholder. Replace this file after running disko (see scripts/new-host.sh
# output for the exact commands) using:
#   sudo nixos-generate-config --no-filesystems --root /mnt
#   cp /mnt/etc/nixos/hardware-configuration.nix hosts/<this-host>/hardware-configuration.nix
{ }
EOF

echo
echo "Created hosts/$HOST (hostname + disk device + NixOS version filled in)."
echo
echo "Next steps:"
echo "  1. Review hosts/$HOST/configuration.nix and disk-config.nix if you want"
echo "     to change anything else about this machine."
echo "  2. Partition and mount the disk:"
echo "       sudo nix run github:nix-community/disko -- --mode destroy,format,mount $HOST_DIR/disk-config.nix"
echo "  3. Generate the real hardware config and copy it in:"
echo "       sudo nixos-generate-config --no-filesystems --root /mnt"
echo "       cp /mnt/etc/nixos/hardware-configuration.nix $HOST_DIR/hardware-configuration.nix"
echo "  4. Make the new files visible to Nix:"
echo "       git -C \"$REPO_ROOT\" add -A"
echo "  5. Install:"
echo "       sudo nixos-install --root /mnt --flake \"$REPO_ROOT#$HOST\""
echo "  6. Reboot, then once you're back on a machine you trust, push the new"
echo "     host folder to GitHub."
