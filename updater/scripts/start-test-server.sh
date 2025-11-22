#!/bin/bash
# Start a simple HTTP server for testing updates

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../test-server"
PORT="${1:-8000}"

# Check if Python is available
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "Error: Python is not installed."
    echo "Please install Python 3 to run the test server."
    exit 1
fi

# Check if test server directory exists and has files
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "Error: Test server directory not found: ${OUTPUT_DIR}"
    echo "Run the setup scripts first:"
    echo "  1. ./generate-keys.sh"
    echo "  2. ./generate-manifest.sh"
    echo "  3. ./sign-manifest.sh"
    exit 1
fi

if [ ! -f "${OUTPUT_DIR}/latest.sig" ]; then
    echo "Warning: latest.sig not found in ${OUTPUT_DIR}"
    echo "Make sure you've run ./sign-manifest.sh"
    echo ""
fi

echo "Starting test HTTP server..."
echo "Server directory: ${OUTPUT_DIR}"
echo "Port: ${PORT}"
echo ""
echo "Update your updater/constants.go:"
echo "  updateServerHost = \"localhost\""
echo "  updateServerPort = ${PORT}"
echo "  updateServerUseHttps = false"
echo ""
echo "Access the server at: http://localhost:${PORT}/"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Change to the server directory and start Python HTTP server
cd "${OUTPUT_DIR}"

# Start the server
${PYTHON_CMD} -m http.server "${PORT}" 2>&1

