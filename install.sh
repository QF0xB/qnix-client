#!/usr/bin/env bash
set -euo pipefail

yesno() {
  local prompt="$1"
  while true; do
    read -rp "$prompt [y/n] " yn
    case "$yn" in
      [Yy]*) return 0;;
      [Nn]*) return 1;;
      *) echo "Please answer yes or no.";;
    esac
  done
}

SUDO="sudo"
[[ -x /run/wrappers/bin/sudo ]] && SUDO="/run/wrappers/bin/sudo"

# Enter a tool environment if needed (do NOT pull sudo from nixpkgs)
if ! command -v disko >/dev/null 2>&1; then
  exec nix shell \
    nixpkgs#util-linux \
    nixpkgs#zfs \
    nixpkgs#cryptsetup \
    nixpkgs#git \
    --command bash "$0" "$@"
fi

# Disk selection (VM special-case like your old script)
if [[ -b "/dev/vda" ]]; then
  DISK="/dev/vda"
else
  echo "Available disks:"
  lsblk -ndo NAME,SIZE,MODEL,TYPE | awk '$4=="disk"{printf "  /dev/%s  %s  %s\n",$1,$2,$3}'
  echo
  read -rp "Enter disk to install to (e.g. /dev/nvme0n1): " DISK
fi

[[ -b "$DISK" ]] || { echo "Not a block device: $DISK" >&2; exit 1; }

echo
echo "Target disk: $DISK"
echo "This will irreversibly wipe the entire disk."
yesno "Proceed?" || exit 0

# Swap size (changeable/removable)
read -rp "Swap size (e.g. 16G) or 0 for none [default: 0]: " SWAP_SIZE
SWAP_SIZE="${SWAP_SIZE:-0}"

# Optional encryption
ENCRYPT=0
if yesno "Use LUKS encryption for ZFS partition?"; then
  ENCRYPT=1
fi

# Optional persist restore (same spirit as your old script)
RESTORE=0
SNAPSHOT_FILE=""
if yesno "Restore /persist from a zfs receive stream file?"; then
  RESTORE=1
  read -rp "Path to snapshot stream file: " SNAPSHOT_FILE
  [[ -f "$SNAPSHOT_FILE" ]] || { echo "No such file: $SNAPSHOT_FILE" >&2; exit 1; }
fi

# Flake selection (same flow)
read -rp "Flake URL (default: github:QF0xB/dotfiles): " REPO
REPO="${REPO:-github:QF0xB/dotfiles}"
read -rp "Flake ref/rev (default: master): " REV
REV="${REV:-master}"
read -rp "Host (flake output) to install: " HOST
[[ -n "$HOST" ]] || { echo "Host must not be empty." >&2; exit 1; }

export DISK SWAP_SIZE ENCRYPT

echo
echo "Running disko (ENCRYPT=$ENCRYPT, SWAP_SIZE=$SWAP_SIZE) ..."
"$SUDO" disko --mode disko ./disko-zfs-optional-luks.nix
"$SUDO" disko --mode mount ./disko-zfs-optional-luks.nix

# Create blank snapshot like your old script
"$SUDO" zfs snapshot zroot/root@blank 2>/dev/null || true

# Optional /persist restore
if [[ "$RESTORE" == "1" ]]; then
  echo "Restoring zroot/persist from stream: $SNAPSHOT_FILE"
  "$SUDO" zfs umount -f zroot/persist >/dev/null 2>&1 || true
  "$SUDO" zfs destroy -r zroot/persist
  "$SUDO" zfs receive -o mountpoint=/persist zroot/persist < "$SNAPSHOT_FILE"
fi

echo
echo "Installing NixOS: ${REPO}/${REV}#${HOST}"
"$SUDO" nixos-install --no-root-password --flake "${REPO}/${REV}#${HOST}" --option tarball-ttl 0

echo
echo "Installation complete. It is now safe to reboot."
