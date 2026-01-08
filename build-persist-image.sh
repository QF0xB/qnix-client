#!/usr/bin/env bash
set -euo pipefail

# make-persist-qcow2.sh
#
# Creates (or validates) a qcow2 disk image with GPT + 2 partitions:
#   p1: ext4 label "nix"     (default 12G)
#   p2: ext4 label "persist" (rest of disk)
#
# Key features:
# - Self-bootstraps dependencies via `nix shell` (no devshell required)
# - Uses NixOS sudo wrapper (/run/wrappers/bin/sudo) to avoid setuid issues
# - Idempotent: if partitions/filesystems already exist, it keeps them (unless FORCE=1)
#
# Usage:
#   ./make-persist-qcow2.sh [persist.qcow2] [disk_size] [p1_size]
#
# Examples:
#   ./make-persist-qcow2.sh
#   ./make-persist-qcow2.sh persist.qcow2 20G 12G
#   FORCE=1 ./make-persist-qcow2.sh persist.qcow2 64G 16G
#   NBD_DEV=/dev/nbd1 ./make-persist-qcow2.sh persist.qcow2 20G 12G

IMG="${1:-persist.qcow2}"
DISK_SIZE="${2:-20G}"
P1_SIZE="${3:-12G}"

NBD_DEV="${NBD_DEV:-/dev/nbd0}"
FORCE="${FORCE:-0}"

# Prefer NixOS setuid sudo wrapper; avoid nix-shell sudo (not setuid in /nix/store)
SUDO="sudo"
if [[ -x /run/wrappers/bin/sudo ]]; then
  SUDO="/run/wrappers/bin/sudo"
fi

need() { command -v "$1" >/dev/null 2>&1; }

# Re-exec inside a nix shell if core tools are missing.
# IMPORTANT: do NOT include nixpkgs#sudo in nix shell; it will not be setuid.
if ! need qemu-img || ! need qemu-nbd || ! need sgdisk || ! need partprobe || ! need lsblk || ! need blkid || ! need mkfs.ext4 || ! need modprobe; then
  exec nix shell \
    nixpkgs#qemu \
    nixpkgs#gptfdisk \
    nixpkgs#parted \
    --command "$0" "$@"
fi

cleanup() {
  set +e
  "$SUDO" qemu-nbd --disconnect "$NBD_DEV" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Safety: refuse to run as root; we use sudo only where needed.
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "Refusing to run as root. Run as a normal user; the script will sudo when needed." >&2
  exit 1
fi

echo "Using sudo: $SUDO"
echo "Image: $IMG"
echo "Disk size: $DISK_SIZE"
echo "Partition 1 size: $P1_SIZE"
echo "NBD device: $NBD_DEV"
echo "FORCE: $FORCE"

# Load NBD kernel module
"$SUDO" modprobe nbd max_part=16

if [[ -e "$IMG" && "$FORCE" == "1" ]]; then
  echo "FORCE=1 set; removing existing $IMG"
  rm -f -- "$IMG"
fi

if [[ ! -e "$IMG" ]]; then
  echo "Creating qcow2: $IMG ($DISK_SIZE)"
  qemu-img create -f qcow2 "$IMG" "$DISK_SIZE" >/dev/null
else
  echo "Using existing qcow2: $IMG"
fi

# Ensure NBD is disconnected before connecting (idempotent)
"$SUDO" qemu-nbd --disconnect "$NBD_DEV" >/dev/null 2>&1 || true

echo "Connecting $IMG -> $NBD_DEV"
"$SUDO" qemu-nbd --connect="$NBD_DEV" "$IMG"

base="$(basename "$NBD_DEV")"

has_p1="$(lsblk -nr -o NAME "$NBD_DEV" 2>/dev/null | awk '{print $1}' | grep -x "${base}p1" || true)"
has_p2="$(lsblk -nr -o NAME "$NBD_DEV" 2>/dev/null | awk '{print $1}' | grep -x "${base}p2" || true)"

if [[ -n "$has_p1" && -n "$has_p2" && "$FORCE" != "1" ]]; then
  echo "Partitions already exist (${NBD_DEV}p1, ${NBD_DEV}p2). Keeping."
else
  echo "Creating GPT + 2 partitions (p1=${P1_SIZE}, p2=rest)"
  "$SUDO" sgdisk --zap-all "$NBD_DEV" >/dev/null
  "$SUDO" sgdisk \
    -n 1:0:+"$P1_SIZE" -t 1:8300 -c 1:nix \
    -n 2:0:0          -t 2:8300 -c 2:persist \
    "$NBD_DEV" >/dev/null

  "$SUDO" partprobe "$NBD_DEV"

  # Wait briefly for partition nodes
  for _ in {1..80}; do
    [[ -b "${NBD_DEV}p1" && -b "${NBD_DEV}p2" ]] && break
    sleep 0.05
  done
fi

P1="${NBD_DEV}p1"
P2="${NBD_DEV}p2"

if [[ ! -b "$P1" || ! -b "$P2" ]]; then
  echo "Error: partition block devices not present: $P1 $P2" >&2
  echo "Try: NBD_DEV=/dev/nbd1 $0 ..." >&2
  exit 1
fi

fmt_if_needed() {
  local dev="$1"
  local label="$2"

  local t
  t="$(blkid -o value -s TYPE "$dev" 2>/dev/null || true)"

  if [[ "$t" == "ext4" && "$FORCE" != "1" ]]; then
    echo "  $dev already ext4; keeping."
    return 0
  fi

  echo "  Formatting $dev as ext4 (label=$label)"
  "$SUDO" mkfs.ext4 -F -L "$label" "$dev" >/dev/null
}

echo "Ensuring filesystems:"
fmt_if_needed "$P1" "nix"
fmt_if_needed "$P2" "persist"

echo
echo "Final layout:"
lsblk -f "$NBD_DEV" || true

echo
echo "Done: $IMG is ready (GPT, ${base}p1 + ${base}p2)."
echo "Disconnecting $NBD_DEV."
# Disconnect handled by trap as well, but do it explicitly for clarity
cleanup
trap - EXIT

