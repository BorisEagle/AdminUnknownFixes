#!/usr/bin/env bash
set -euo pipefail

# Build AdminUnknownFixes as a Factorio mod zip and install it into the
# Windows Factorio mods directory from WSL.
#
# Override FACTORIO_MODS if your Factorio profile is elsewhere:
#   FACTORIO_MODS="/mnt/c/Users/boris/AppData/Roaming/Factorio/mods" ./scripts/package-install-wsl.sh

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required. Install it with: sudo apt install -y jq" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "ERROR: rsync is required. Install it with: sudo apt install -y rsync" >&2
  exit 1
fi

MOD_NAME="$(jq -r .name info.json)"
VERSION="$(jq -r .version info.json)"
FOLDER="${MOD_NAME}_${VERSION}"
OUT="${FOLDER}.zip"

WINDOWS_USER="${WINDOWS_USER:-${USER:-boris}}"
FACTORIO_MODS="${FACTORIO_MODS:-/mnt/c/Users/${WINDOWS_USER}/AppData/Roaming/Factorio/mods}"

if [ ! -d "$FACTORIO_MODS" ]; then
  echo "Creating Factorio mods directory: $FACTORIO_MODS"
  mkdir -p "$FACTORIO_MODS"
fi

echo "Building $OUT from $ROOT"
rm -rf "/tmp/$FOLDER" "$OUT"
mkdir -p "/tmp/$FOLDER"

rsync -a ./ "/tmp/$FOLDER/" \
  --exclude ".git" \
  --exclude ".github" \
  --exclude "*.zip" \
  --exclude ".vscode" \
  --exclude ".codex" \
  --exclude "dist"

(
  cd /tmp
  zip -qr "$ROOT/$OUT" "$FOLDER"
)

rm -rf "/tmp/$FOLDER"

echo "Removing stale unpacked AdminUnknownFixes folders from $FACTORIO_MODS"
find "$FACTORIO_MODS" -maxdepth 1 -type d -iname 'AdminUnknownFixes_*' -print -exec rm -rf {} +

echo "Installing $OUT to $FACTORIO_MODS"
cp -v "$OUT" "$FACTORIO_MODS/"

echo
echo "Installed mods matching AdminUnknownFixes:"
ls -1 "$FACTORIO_MODS" | grep -i '^AdminUnknownFixes' || true

echo
echo "Done. Start Factorio and test. If Windows locks the old zip, close Factorio completely and rerun this script."
