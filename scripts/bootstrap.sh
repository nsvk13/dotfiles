#!/usr/bin/env bash
# Put this flake onto a machine that already runs a fresh NixOS install.
#
#   nix-shell -p git --run "git clone https://github.com/nsvk13/dotfiles ~/.dotfiles"
#   ~/.dotfiles/scripts/bootstrap.sh m7        # or: tuf
#
# Copies the machine's hardware-configuration.nix into hosts/<host>/, stages it
# (flakes only see files tracked by git), sanity-checks the GPU bus IDs and switches.
set -euo pipefail

command -v git >/dev/null || exec nix-shell -p git --run "$(printf '%q ' "$0" "$@")"

host="${1:-}"
repo="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "$host" || ! -f "$repo/hosts/$host/default.nix" ]]; then
  echo "usage: $0 <host>   (available: $(ls "$repo/hosts" | tr '\n' ' '))" >&2
  exit 1
fi

hw="$repo/hosts/$host/hardware-configuration.nix"

if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
  cp /etc/nixos/hardware-configuration.nix "$hw"
else
  sudo nixos-generate-config --show-hardware-config >"$hw"
fi
git -C "$repo" add "$hw"
echo ">> hosts/$host/hardware-configuration.nix staged"

# The graphical installer keeps LUKS keyfile / encrypted swap settings in
# configuration.nix, not in hardware-configuration.nix. Losing them = no boot.
if grep -qE 'luks|initrd\.secrets' /etc/nixos/configuration.nix 2>/dev/null; then
  echo "!! /etc/nixos/configuration.nix contains LUKS settings:" >&2
  grep -nE 'luks|initrd\.secrets|crypto_keyfile' /etc/nixos/configuration.nix >&2
  echo "!! Move them into hosts/$host/default.nix first, then re-run with FORCE=1." >&2
  [[ "${FORCE:-0}" == 1 ]] || exit 1
fi

# PRIME bus IDs are hardcoded per host; compare them with the real hardware.
if grep -q 'BusId' "$repo/hosts/$host/default.nix"; then
  echo ">> GPUs on this machine (lspci domain:bus:dev.fn is HEX, BusId is DECIMAL):"
  lspci -D | grep -E 'VGA|3D|Display' || true
  grep -E 'BusId' "$repo/hosts/$host/default.nix"
  read -rp ">> Do the bus IDs match? [y/N] " ok
  [[ "$ok" == [yY] ]] || { echo "Fix hosts/$host/default.nix and re-run." >&2; exit 1; }
fi

sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-rebuild switch --flake "$repo#$host"

echo ">> Done. From now on: 'rebuild' to apply changes, 'update' to update inputs."
