#!/bin/bash
# Set version number in version/version.go and installer/pangolin.wxs
# Usage: ./set-version.sh <version>
#   version: Version string (e.g., "1.0.3")

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <version>"
    echo "  version: Version string (e.g., \"1.0.3\")"
    echo ""
    echo "Example:"
    echo "  $0 1.0.3"
    exit 1
fi

VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."
VERSION_GO="${PROJECT_ROOT}/version/version.go"
INSTALLER_WXS="${PROJECT_ROOT}/pangolin.wxs"

# Validate version format (basic check: should contain at least one dot)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?(-[a-zA-Z0-9]+)?$ ]]; then
    echo "Warning: Version format may be invalid. Expected format: X.Y.Z or X.Y.Z-suffix"
    echo "  Example: 1.0.3 or 1.0.3-beta"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Check if files exist
if [ ! -f "${VERSION_GO}" ]; then
    echo "Error: version/version.go not found: ${VERSION_GO}"
    exit 1
fi

if [ ! -f "${INSTALLER_WXS}" ]; then
    echo "Error: installer/pangolin.wxs not found: ${INSTALLER_WXS}"
    exit 1
fi

echo "Setting version to: ${VERSION}"
echo ""

# Update version/version.go
echo "Updating version/version.go..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/Number = \".*\"/Number = \"${VERSION}\"/" "${VERSION_GO}"
else
    # Linux
    sed -i "s/Number = \".*\"/Number = \"${VERSION}\"/" "${VERSION_GO}"
fi
echo "✓ Updated version/version.go"

# Update installer/pangolin.wxs
echo "Updating installer/pangolin.wxs..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/Version=\"[^\"]*\"/Version=\"${VERSION}\"/" "${INSTALLER_WXS}"
else
    # Linux
    sed -i "s/Version=\"[^\"]*\"/Version=\"${VERSION}\"/" "${INSTALLER_WXS}"
fi
echo "✓ Updated installer/pangolin.wxs"

echo ""
echo "✓ Version updated to ${VERSION} in both files"
echo ""
echo "Next steps:"
echo "  1. Review the changes:"
echo "     git diff version/version.go installer/pangolin.wxs"
echo "  2. Build the application:"
echo "     make build"
echo "  3. Build MSI installer:"
echo "     scripts/build-msi.bat"

