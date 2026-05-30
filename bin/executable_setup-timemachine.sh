#!/usr/bin/env bash
# Sets up Time Machine to back up to smb://nas.home.solaegis.com/timemachine/
#
# Prerequisites:
#   - Credentials for nas.home.solaegis.com stored in Keychain (account: lvavasour)
#   - Terminal (or whichever app runs this) in:
#     System Settings > Privacy & Security > Full Disk Access
#     (required for `tmutil setdestination`)

set -euo pipefail

NAS_HOST="nas.home.solaegis.com"
SHARE="timemachine"
SMB_USER="lvavasour"
MOUNT_POINT="/Volumes/${SHARE}"
MOUNT_TIMEOUT=20

# Already configured?
if tmutil destinationinfo 2>/dev/null | grep -q "${NAS_HOST}"; then
    echo "Time Machine is already configured for ${NAS_HOST}:"
    tmutil destinationinfo
    exit 0
fi

# Mount the share (Keychain supplies the password automatically)
if ! mount | grep -q "${NAS_HOST}/${SHARE}"; then
    echo "Mounting smb://${SMB_USER}@${NAS_HOST}/${SHARE}..."
    open "smb://${SMB_USER}@${NAS_HOST}/${SHARE}"

    for i in $(seq 1 ${MOUNT_TIMEOUT}); do
        mount | grep -q "${NAS_HOST}/${SHARE}" && break
        sleep 1
    done
fi

if ! mount | grep -q "${NAS_HOST}/${SHARE}"; then
    echo "Error: timed out waiting for ${MOUNT_POINT} to mount." >&2
    exit 1
fi

echo "Mounted at ${MOUNT_POINT}"

# Register as Time Machine destination
# Requires sudo AND Full Disk Access for the calling terminal.
echo "Registering Time Machine destination (sudo required)..."
sudo tmutil setdestination -a "${MOUNT_POINT}"

echo ""
echo "Destination registered:"
tmutil destinationinfo

# Unmount — Time Machine auto-mounts/unmounts on each backup cycle
diskutil unmount "${MOUNT_POINT}"
echo ""
echo "Done. Time Machine will mount the share automatically before each backup."
