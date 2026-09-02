#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Dependencies ──────────────────────────────────────────────
DEPS=(niri quickshell foot fuzzel fish starship)
MISSING=()
for dep in "${DEPS[@]}"; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING+=("$dep")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Missing dependencies: ${MISSING[*]}"
  echo "Install them first, e.g.:"
  echo "  sudo pacman -S ${MISSING[*]}"
  exit 1
fi

# ── Install all configs from the .config/ mirror ──────────────
SRC="$ROOT/.config"
DST="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "→ Installing configs to $DST"
mkdir -p "$DST"
rsync -a "$SRC/" "$DST/"
echo "  done"

echo ""
echo "✓ All done. Start the shell: inir run"
echo "  (or log into your display manager / niri session)"