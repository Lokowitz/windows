#!/bin/bash
# Master script to set up the complete test environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Pangolin Updater Test Environment Setup"
echo "=========================================="
echo ""

# Step 1: Generate keys
echo "Step 1: Generating Ed25519 keys..."
if [ ! -f "${SCRIPT_DIR}/../test-keys/release.sec" ]; then
    "${SCRIPT_DIR}/generate-keys.sh"
    echo ""
else
    echo "✓ Keys already exist, skipping..."
    echo ""
fi

# Step 2: Extract public key
echo "Step 2: Extracting public key for constants.go..."
echo ""
"${SCRIPT_DIR}/extract-public-key.sh"
echo ""
echo "Please update updater/constants.go with the public key shown above."
echo ""
read -p "Press Enter to continue after updating constants.go..."
echo ""

# Step 3: Generate manifest
echo "Step 3: Generating file list manifest..."
"${SCRIPT_DIR}/generate-manifest.sh"
echo ""

# Step 4: Sign manifest
echo "Step 4: Signing manifest..."
"${SCRIPT_DIR}/sign-manifest.sh"
echo ""

# Step 5: Copy MSI files to test server
echo "Step 5: Copying MSI files to test server directory..."
BUILD_DIR="${SCRIPT_DIR}/../../build"
OUTPUT_DIR="${SCRIPT_DIR}/../test-server"

if [ -d "${BUILD_DIR}" ]; then
    MSI_FILES=$(find "${BUILD_DIR}" -name "*.msi" -type f 2>/dev/null || true)
    if [ -n "${MSI_FILES}" ]; then
        for MSI_FILE in ${MSI_FILES}; do
            echo "  Copying: $(basename "${MSI_FILE}")"
            cp "${MSI_FILE}" "${OUTPUT_DIR}/"
        done
        echo "✓ MSI files copied"
    else
        echo "  No MSI files found in ${BUILD_DIR}"
        echo "  You can manually copy MSI files to ${OUTPUT_DIR}/"
    fi
else
    echo "  Build directory not found: ${BUILD_DIR}"
    echo "  You can manually copy MSI files to ${OUTPUT_DIR}/"
fi
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Test server files are in: ${OUTPUT_DIR}/"
echo ""
echo "To start the test server, run:"
echo "  ./start-test-server.sh [port]"
echo ""
echo "Default port is 8000. You can specify a different port:"
echo "  ./start-test-server.sh 8080"
echo ""
echo "Don't forget to:"
echo "  1. Update updater/constants.go with your test server settings"
echo "  2. Set PANGOLIN_ALLOW_DEV_UPDATES=1 when testing"
echo "  3. Ensure your test MSI version is higher than version/version.go"

