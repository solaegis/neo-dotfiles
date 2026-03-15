#!/bin/sh
# Install Mac App Store apps by ID (macOS only, run once). Sign into App Store first.
# mas-ids.txt is generated from .chezmoidata.toml at apply time (lines: "id   # app name").
# We parse each line and use only the leading numeric ID so comments are preserved in the file.
set -e
if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi
if ! command -v mas >/dev/null 2>&1; then
  exit 0
fi
list="$HOME/mas-ids.txt"
if [ ! -f "$list" ]; then
  exit 0
fi
# Lines are "id   # app name"; we use only the first field (ID)
while read -r id rest; do
  [ -z "$id" ] && continue
  case "$id" in
    ""|\#*) continue ;;
    [0-9]*) mas install "$id" 2>/dev/null || true ;;
  esac
done < "$list"
