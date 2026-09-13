#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/yazi"
DEST="$HOME/.config/yazi"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: source directory not found: $SRC" >&2
  exit 1
fi

for TOOL in yazi ya; do
  if ! command -v "$TOOL" >/dev/null 2>&1; then
    echo "ERROR: $TOOL not found in PATH. Install Yazi 25.5.28+ first:" >&2
    echo "  https://yazi-rs.github.io/docs/installation" >&2
    exit 1
  fi
done
YAZI_VERSION_OUTPUT="$(yazi --version 2>/dev/null || true)"
if [[ ! "$YAZI_VERSION_OUTPUT" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  echo "ERROR: could not read the Yazi version (yazi --version printed: '$YAZI_VERSION_OUTPUT')." >&2
  exit 1
fi
YAZI_VERSION="${BASH_REMATCH[0]}"
if ((BASH_REMATCH[1] * 10000 + BASH_REMATCH[2] * 100 + BASH_REMATCH[3] < 250528)); then
  echo "ERROR: Yazi $YAZI_VERSION found, this config needs Yazi 25.5.28+." >&2
  exit 1
fi
echo "Found Yazi $YAZI_VERSION"

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git not found in PATH — ya pkg downloads packages with it (sudo apt install git)." >&2
  exit 1
fi

if [[ -n "${YAZI_CONFIG_HOME:-}" && "$YAZI_CONFIG_HOME" != "$DEST" ]]; then
  echo "WARNING: YAZI_CONFIG_HOME is set to $YAZI_CONFIG_HOME — yazi will not read $DEST." >&2
fi

if [[ -e "$DEST" || -L "$DEST" ]]; then
  BACKUP="${DEST}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Backing up existing config: $DEST -> $BACKUP"
  mv "$DEST" "$BACKUP"
fi

echo "Installing config: $SRC -> $DEST"
mkdir -p "$(dirname "$DEST")"
cp -r "$SRC" "$DEST"

echo "Installing the latest version of every package in $DEST/package.toml"
if ! YAZI_CONFIG_HOME="$DEST" ya pkg upgrade --discard; then
  echo "ERROR: ya pkg upgrade failed. The config is installed without its packages;" >&2
  echo "  check the network access to GitHub and run ./install.sh again." >&2
  exit 1
fi

echo "Done. Run yazi; run ./install.sh again to update the packages."
