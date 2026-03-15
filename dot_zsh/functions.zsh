# =============================================================================
# Helper functions. Portable (macOS + Linux).
# =============================================================================

# Create a dir and cd into it
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

# Quick local HTTP server (port optional)
serve() {
  local port="${1:-8000}"
  if command -v python3 &>/dev/null; then
    python3 -m http.server "$port"
  else
    echo "python3 not found"
    return 1
  fi
}

# Extract common archives by extension
extract() {
  local f="$1"
  [[ -z "$f" || ! -r "$f" ]] && { echo "Usage: extract <file>" >&2; return 1; }
  case "$f" in
    (*.tar.gz|*.tgz)  tar -xzf "$f" ;;
    (*.tar.bz2|*.tbz2) tar -xjf "$f" ;;
    (*.tar.xz)        tar -xJf "$f" ;;
    (*.zip)           unzip "$f" ;;
    (*.gz)            gunzip -k "$f" ;;
    (*)               echo "Unknown extension: $f" >&2; return 1 ;;
  esac
}
