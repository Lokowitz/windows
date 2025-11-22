#!/bin/bash
# Extract base64 public key from signify public key file for use in constants.go

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="${SCRIPT_DIR}/../test-keys"
PUBLIC_KEY_FILE="${KEYS_DIR}/release.pub"

if [ ! -f "${PUBLIC_KEY_FILE}" ]; then
    echo "Error: Public key file not found: ${PUBLIC_KEY_FILE}"
    echo "Run ./generate-keys.sh first"
    exit 1
fi

# Read the public key file (signify format: "untrusted comment: ..." followed by base64 key)
# Extract just the base64 line
PUBLIC_KEY=$(grep -v "^untrusted comment:" "${PUBLIC_KEY_FILE}" | head -n 1 | tr -d '\n')

if [ -z "${PUBLIC_KEY}" ]; then
    echo "Error: Could not extract public key from ${PUBLIC_KEY_FILE}"
    exit 1
fi

echo "Public key (base64):"
echo "${PUBLIC_KEY}"
echo ""
echo "Add this to updater/constants.go as releasePublicKeyBase64:"
echo ""
echo "const ("
echo "    releasePublicKeyBase64 = \"${PUBLIC_KEY}\""
echo "    ..."
echo ")"
echo ""
echo "Full line to add:"
echo "    releasePublicKeyBase64 = \"${PUBLIC_KEY}\""

