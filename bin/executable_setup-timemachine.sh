#!/usr/bin/env bash
# Sets up a network SMB share as a Time Machine destination.
#
# Configuration: edit the variables below, or override via environment:
#   NAS_HOST=mynas.local SMB_USER=john SHARE=backups ./setup-timemachine.sh
#
# Prerequisites:
#   - Credentials stored in Keychain for NAS_HOST / SMB_USER
#     (add via: Finder → Connect to Server → smb://user@host/share, tick "Remember")
#   - sudo access

set -euo pipefail

NAS_HOST="${NAS_HOST:-nas.home.solaegis.com}"
SHARE="${SHARE:-timemachine}"
SMB_USER="${SMB_USER:-lvavasour}"

SMB_URL="smb://${SMB_USER}@${NAS_HOST}/${SHARE}"

# Already configured?
if tmutil destinationinfo 2>/dev/null | grep -q "${NAS_HOST}"; then
    echo "Time Machine is already configured for ${NAS_HOST}:"
    tmutil destinationinfo
    exit 0
fi

# Retrieve password from Keychain (avoids embedding credentials in plain text)
echo "Looking up Keychain password for ${SMB_USER}@${NAS_HOST}..."
if ! SMB_PASS=$(security find-internet-password -s "${NAS_HOST}" -a "${SMB_USER}" -w 2>/dev/null); then
    echo "Error: no Keychain entry found for ${SMB_USER}@${NAS_HOST}." >&2
    echo "Connect to the share in Finder first (tick 'Remember this password')." >&2
    exit 1
fi

# Register as Time Machine destination (password embedded in URL so sudo can use it)
echo "Registering Time Machine destination (sudo required)..."
sudo tmutil setdestination -a "smb://${SMB_USER}:${SMB_PASS}@${NAS_HOST}/${SHARE}"

echo ""
echo "Destination registered:"
tmutil destinationinfo
echo ""
echo "Done. Time Machine will mount the share automatically before each backup."
