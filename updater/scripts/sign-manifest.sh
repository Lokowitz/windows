#!/bin/bash
# Sign the file list manifest with Ed25519 private key

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="${SCRIPT_DIR}/../test-keys"
OUTPUT_DIR="${SCRIPT_DIR}/../test-server"
SECRET_KEY_FILE="${KEYS_DIR}/release.sec"
MANIFEST_FILE="${OUTPUT_DIR}/filelist.txt"
SIGNED_MANIFEST="${OUTPUT_DIR}/latest.sig"

# Check if signify is available
if ! command -v signify &> /dev/null; then
    echo "Error: 'signify' is not installed."
    echo "Install it first (see generate-keys.sh for instructions)"
    exit 1
fi

# Check if secret key exists
if [ ! -f "${SECRET_KEY_FILE}" ]; then
    echo "Error: Secret key not found: ${SECRET_KEY_FILE}"
    echo "Run ./generate-keys.sh first"
    exit 1
fi

# Check if manifest exists
if [ ! -f "${MANIFEST_FILE}" ]; then
    echo "Error: Manifest file not found: ${MANIFEST_FILE}"
    echo "Run ./generate-manifest.sh first"
    exit 1
fi

echo "Signing manifest file..."

# Sign the manifest
# -S: sign
# -e: embed the signature in the file
# -s: secret key file
# -m: message file to sign
signify -S -e -s "${SECRET_KEY_FILE}" -m "${MANIFEST_FILE}"

# The signed file will be created as ${MANIFEST_FILE}.sig
SIGNED_OUTPUT="${MANIFEST_FILE}.sig"
if [ ! -f "${SIGNED_OUTPUT}" ]; then
    echo "Error: Signed file was not created"
    exit 1
fi

# Copy to latest.sig (the filename expected by the updater)
cp "${SIGNED_OUTPUT}" "${SIGNED_MANIFEST}"

echo ""
echo "✓ Manifest signed successfully!"
echo ""
echo "Signed manifest: ${SIGNED_MANIFEST}"
echo ""
echo "You can now serve this file from your test server at the path specified in"
echo "updater/constants.go (latestVersionPath)."
echo ""
echo "To start a test server, run:"
echo "  ./start-test-server.sh"

