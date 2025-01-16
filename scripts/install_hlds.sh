#!/bin/bash
set -eu

# Environment variables
HLDS_DIR=${HLDS_DIR:-"/hlds"}       # Default installation directory
HLDS_BUILD=${HLDS_BUILD:-"8684"}    # Default HLDS version if not provided
HLDS_URL=${HLDS_URL:-"https://github.com/hun1er/hlds-builds/releases/download/$HLDS_BUILD/hlds-$HLDS_BUILD-linux.tar.gz"}                       # Default URL if not provided
HLDS_CHECKSUM_URL=${HLDS_CHECKSUM_URL:-"https://github.com/hun1er/hlds-builds/releases/download/$HLDS_BUILD/hlds-$HLDS_BUILD-linux.tar.sha256"} # Default checksum URL
HLDS_RUN_FILE="$HLDS_DIR/hlds_run"

# Temporary file paths
TMP_HLDS_ARCHIVE="/tmp/hlds-$HLDS_BUILD-linux.tar.gz"
TMP_HLDS_CHECKSUM="/tmp/hlds-$HLDS_BUILD-linux.tar.sha256"

# Ensure the target directory exists
mkdir -p "$HLDS_DIR"

# Download HLDS archive
echo "Downloading HLDS archive from: $HLDS_URL"
wget --show-progress -O "$TMP_HLDS_ARCHIVE" "$HLDS_URL"

# Download checksum
echo "Downloading checksum file from: $HLDS_CHECKSUM_URL"
wget -q -O "$TMP_HLDS_CHECKSUM" "$HLDS_CHECKSUM_URL"

# Verify checksum
echo "Verifying archive checksum..."
cd /tmp
sha256sum --check "$TMP_HLDS_CHECKSUM"

# Extract HLDS archive
echo "Extracting HLDS archive to: $HLDS_DIR"
tar -xzf "$TMP_HLDS_ARCHIVE" -C "$HLDS_DIR"

# Check if the hlds_run file exists
if [[ ! -f "$HLDS_RUN_FILE" ]]; then
    echo "Error: File '$HLDS_RUN_FILE' not found!"
    exit 1
fi

# Replace "ulimit -c 2000" with "ulimit -c unlimited"
sed -i 's/ulimit -c 2000/ulimit -c unlimited/' "$HLDS_RUN_FILE"

# Confirm the change
if grep -q "ulimit -c unlimited" "$HLDS_RUN_FILE"; then
    echo "Successfully updated '$HLDS_RUN_FILE' to use 'ulimit -c unlimited'."
else
    echo "Failed to update '$HLDS_RUN_FILE'. Please check the file manually."
    exit 1
fi

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f "$TMP_HLDS_ARCHIVE" "$TMP_HLDS_CHECKSUM"

echo "HLDS setup completed successfully in: $HLDS_DIR"
