#!/bin/bash
# Generate a file list with BLAKE2b-256 hashes for MSI files
# Outputs to build/ directory for production use
# Usage: ./generate-manifest.sh [msi-file1] [msi-file2] ...
#   If no files specified, uses all .msi files in build/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
BUILD_DIR="${PROJECT_ROOT}/build"
MANIFEST_FILE="${BUILD_DIR}/filelist.txt"

# Check if b2sum is available
if ! command -v b2sum &> /dev/null; then
    echo "Error: 'b2sum' is not installed."
    echo ""
    echo "Installation options:"
    echo "  macOS:   brew install coreutils (provides b2sum)"
    echo "  Linux:   Usually pre-installed"
    echo "  Windows: Use WSL or download from a coreutils package"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p "${BUILD_DIR}"

echo "Generating file list with BLAKE2b-256 hashes..."
echo "Output directory: ${BUILD_DIR}"

# Find all MSI files in build directory if no files specified
if [ $# -eq 0 ]; then
    echo "Looking for MSI files in: ${BUILD_DIR}"
    MSI_FILES=$(find "${BUILD_DIR}" -name "*.msi" -type f 2>/dev/null || true)
    
    if [ -z "${MSI_FILES}" ]; then
        echo "Error: No MSI files found in ${BUILD_DIR}"
        echo ""
        echo "You can specify MSI files manually:"
        echo "  $0 /path/to/file1.msi /path/to/file2.msi"
        exit 1
    fi
else
    MSI_FILES="$@"
fi

# Generate hashes
echo "Processing MSI files..."
> "${MANIFEST_FILE}"  # Clear/create file

for MSI_FILE in ${MSI_FILES}; do
    if [ ! -f "${MSI_FILE}" ]; then
        echo "Warning: File not found: ${MSI_FILE}"
        continue
    fi
    
    echo "  Hashing: $(basename "${MSI_FILE}")"
    
    # Generate BLAKE2b-256 hash (256 bits = 32 bytes = 64 hex characters)
    HASH=$(b2sum -l 256 "${MSI_FILE}" | awk '{print $1}')
    FILENAME=$(basename "${MSI_FILE}")
    
    # Append to manifest: "hash  filename"
    echo "${HASH}  ${FILENAME}" >> "${MANIFEST_FILE}"
done

if [ ! -s "${MANIFEST_FILE}" ]; then
    echo "Error: No files were processed. Manifest file is empty."
    exit 1
fi

echo ""
echo "✓ File list generated: ${MANIFEST_FILE}"
echo ""
echo "Next step: Sign the manifest with:"
echo "  ./sign-manifest.sh <secret-key-file>"
echo ""
echo "Contents:"
cat "${MANIFEST_FILE}"

