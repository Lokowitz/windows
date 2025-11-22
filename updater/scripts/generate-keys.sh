#!/bin/bash
# Generate Ed25519 key pair for signing update manifests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="${SCRIPT_DIR}/../test-keys"
PUBLIC_KEY_FILE="${KEYS_DIR}/release.pub"
SECRET_KEY_FILE="${KEYS_DIR}/release.sec"

echo "Generating Ed25519 key pair for update signing..."

# Check if signify is available
if ! command -v signify &> /dev/null; then
    echo "Error: 'signify' is not installed."
    echo ""
    echo "Installation options:"
    echo "  macOS:   brew install signify-osx"
    echo "  Linux:   Install from your distribution's package manager"
    echo "  Windows: Download from OpenBSD or use WSL"
    exit 1
fi

# Create keys directory
mkdir -p "${KEYS_DIR}"

# Generate key pair
signify -G -n -p "${PUBLIC_KEY_FILE}" -s "${SECRET_KEY_FILE}"

echo ""
echo "✓ Keys generated successfully!"
echo ""
echo "Public key:  ${PUBLIC_KEY_FILE}"
echo "Secret key:  ${SECRET_KEY_FILE}"
echo ""
echo "⚠️  Keep the secret key (release.sec) secure and never commit it to version control!"
echo ""
echo "To extract the base64 public key for constants.go, run:"
echo "  ./extract-public-key.sh"
echo ""
echo "Or manually extract from ${PUBLIC_KEY_FILE}"

