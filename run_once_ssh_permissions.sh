#!/bin/sh
# Create ~/.ssh with mode 700 if missing; fix permissions on config and key files.
set -e
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ -f "$HOME/.ssh/config" ]; then chmod 600 "$HOME/.ssh/config"; fi
for key in "$HOME/.ssh"/id_ed25519 "$HOME/.ssh"/id_rsa "$HOME/.ssh"/id_ed25519_acxiom "$HOME/.ssh"/id_ed25519_solaegis "$HOME/.ssh"/id_ed25519_dadandlad "$HOME/.ssh"/id_ed25519_nuvent; do
  if [ -f "$key" ]; then chmod 600 "$key"; fi
done
