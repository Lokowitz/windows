#!/bin/bash
# Extract base64 public key from signify public key file for use in constants.go
# Usage: ./extract-public-key.sh <public-key-file>
#   public-key-file: Path to the release.pub file

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <public-key-file>"
    echo "  public-key-file: Path to the release.pub file"
    echo ""
    echo "Example:"
    echo "  $0 ../signing-keys/release.pub"
    exit 1
fi

PUBLIC_KEY_FILE="$1"

if [ ! -f "${PUBLIC_KEY_FILE}" ]; then
    echo "Error: Public key file not found: ${PUBLIC_KEY_FILE}"
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

