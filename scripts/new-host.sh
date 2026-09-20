#!/usr/bin/env bash
# Scaffold a new host, ready to install with nixos-anywhere.
#
# Run this on any machine with Nix (it does NOT need to be the target
# machine — see nixos-anywhere's docs: https://nix-community.github.io/nixos-anywhere/quickstart.html).
#
# Usage: scripts/new-host.sh <new-hostname>
#
# Per nixos-anywhere's documented process, this script only does the two
# things that are genuinely manual/required and NOT automated by
# nixos-anywhere itself:
#   - Identifying the target's disk (nixos-anywhere docs, step 4: you must
#     run `lsblk` on the target and edit disk-config.nix yourself)
#   - Creating a placeholder hardware-configuration.nix so the flake can
#     evaluate (nixos-anywhere docs, step 8: the import must already exist;
#     nixos-anywhere then generates the REAL contents automatically during
#     install via --generate-hardware-config)
#
# It deliberately does NOT run disko, generate a real hardware config, or
# run nixos-install — nixos-anywhere does all of that itself, remotely, in
# one command (printed at the end of this script). Running those manually
# would just be duplicating what the tool already does.

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

echo "On the TARGET machine (booted from a NixOS installer USB), run 'lsblk'"
echo "to find its disk name, e.g.:"
echo
echo "  NAME        SIZE MODEL"
echo "  nvme0n1     1.8T ..."
echo

read -rp "Target disk name (e.g. nvme0n1, sda): " DISK
DISK_PATH="/dev/$DISK"

echo
echo "!! nixos-anywhere will DESTROY ALL DATA on $DISK_PATH on the target. !!"
read -rp "Type the disk name again to confirm ($DISK): " CONFIRM
if [ "$CONFIRM" != "$DISK" ]; then
  echo "Confirmation did not match — aborting, nothing was changed." >&2
  exit 1
fi

mkdir -p "$HOST_DIR"
cp "$TEMPLATE_DIR/configuration.nix" "$HOST_DIR/configuration.nix"
cp "$TEMPLATE_DIR/disk-config.nix" "$HOST_DIR/disk-config.nix"

sed -i "s/networking.hostName = \"[^\"]*\";/networking.hostName = \"$HOST\";/" "$HOST_DIR/configuration.nix"
sed -i "s#device = \"[^\"]*\";#device = \"$DISK_PATH\";#" "$HOST_DIR/disk-config.nix"

# system.stateVersion should match the NixOS release on the installer USB
# you're using for this install, not necessarily this control machine's.
# Edit hosts/$HOST/configuration.nix if it needs to be different.

cat > "$HOST_DIR/hardware-configuration.nix" <<'EOF'
# Placeholder. nixos-anywhere overwrites this automatically during install
# (via the --generate-hardware-config flag) — do not fill this in by hand.
{ }
EOF

echo
echo "Created hosts/$HOST."
echo
echo "Next steps, per https://nix-community.github.io/nixos-anywhere/quickstart.html :"
echo
echo "  1. Boot the target from a NixOS installer USB, connect it to a network."
echo "  2. On the target's own console, set a password for SSH access:"
echo "       passwd"
echo "     and find its IP address with:"
echo "       ip addr"
echo "  3. Make the new files visible to Nix (from this repo):"
echo "       git -C \"$REPO_ROOT\" add -A"
echo "  4. (Recommended) test the config in a VM first:"
echo "       nix run github:nix-community/nixos-anywhere -- --flake \"$REPO_ROOT#$HOST\" --vm-test"
echo "  5. Install for real — this one command partitions the disk, generates"
echo "     the real hardware config, and installs NixOS, all remotely:"
echo "       nix run github:nix-community/nixos-anywhere -- \\"
echo "         --generate-hardware-config nixos-generate-config $HOST_DIR/hardware-configuration.nix \\"
echo "         --flake \"$REPO_ROOT#$HOST\" \\"
echo "         --target-host nixos@<target-ip>"
echo "  6. Once it reboots into the new system, push the new host folder to GitHub."
