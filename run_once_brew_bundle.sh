#!/bin/sh
# Install Homebrew formulae/casks from Brewfile (run once per machine).
# Brewfile is generated from .chezmoidata.toml at apply time and written to ~/Brewfile.
set -e
if command -v brew >/dev/null 2>&1 && [ -f "$HOME/Brewfile" ]; then
  brew bundle install --file="$HOME/Brewfile"
fi
