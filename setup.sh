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

# ── Shell (Quickshell config) ──────────────────────────────────
SHELL_DST="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/inir"
echo "→ Installing shell to $SHELL_DST"
mkdir -p "$SHELL_DST"
cp -r "$ROOT/shell/"* "$SHELL_DST/"
echo "  done"

# ── Niri ───────────────────────────────────────────────────────
NIRI_DST="${XDG_CONFIG_HOME:-$HOME/.config}/niri"
echo "→ Installing niri config to $NIRI_DST"
mkdir -p "$NIRI_DST/config.d"
cp "$ROOT/niri/config.kdl" "$NIRI_DST/"
cp "$ROOT/niri/config.d/"*.kdl "$NIRI_DST/config.d/"
echo "  done"

# ── Terminal ───────────────────────────────────────────────────
if [ -d "$ROOT/foot" ]; then
  cp "$ROOT/foot/"* "${XDG_CONFIG_HOME:-$HOME/.config}/foot/" 2>/dev/null || true
  echo "→ foot config installed"
fi
if [ -d "$ROOT/kitty" ]; then
  cp "$ROOT/kitty/"* "${XDG_CONFIG_HOME:-$HOME/.config}/kitty/" 2>/dev/null || true
  echo "→ kitty config installed"
fi

# ── Launcher ───────────────────────────────────────────────────
if [ -d "$ROOT/fuzzel" ]; then
  mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel"
  cp "$ROOT/fuzzel/"* "${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/"
  echo "→ fuzzel config installed"
fi

# ── GTK ────────────────────────────────────────────────────────
if [ -d "$ROOT/gtk-3.0" ]; then
  cp "$ROOT/gtk-3.0/"* "${XDG_CONFIG_HOME:-$HOME}/.config/gtk-3.0/" 2>/dev/null || true
  echo "→ GTK3 config installed"
fi

# ── Prompt ─────────────────────────────────────────────────────
if [ -f "$ROOT/starship.toml" ]; then
  cp "$ROOT/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/"
  echo "→ starship config installed"
fi

# ── Fish ───────────────────────────────────────────────────────
if [ -d "$ROOT/fish" ]; then
  mkdir -p "${XDG_CONFIG_HOME:-$HOME}/.config/fish"
  cp "$ROOT/fish/"* "${XDG_CONFIG_HOME:-$HOME}/.config/fish/"
  echo "→ fish config installed"
fi

# ── MIME ───────────────────────────────────────────────────────
if [ -f "$ROOT/mimeapps.list" ]; then
  cp "$ROOT/mimeapps.list" "${XDG_CONFIG_HOME:-$HOME/.config}/"
  echo "→ MIME associations installed"
fi

echo ""
echo "✓ All done. Start the shell: inir run"
