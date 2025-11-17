#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/versions.json"

echo "Fetching latest Bambu Studio release from GitHub..."
if [ -n "${GITHUB_TOKEN:-}" ]; then
    LATEST_RELEASE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/bambulab/BambuStudio/releases/latest)
else
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/bambulab/BambuStudio/releases/latest)
fi

# Use --raw-output and pipe through sed to handle potential control characters
LATEST_VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name // empty' | sed 's/^v//')

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not fetch latest version"
    exit 1
fi

echo "Latest version: $LATEST_VERSION"

# Read current version
CURRENT_VERSION=$(jq -r '.["x86_64-linux"].version' "$VERSIONS_FILE")
echo "Current version: $CURRENT_VERSION"

if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

echo "Updating to version $LATEST_VERSION..."

# Find the Ubuntu 24.04 AppImage asset
ASSET_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[]? | select(.name | test("ubuntu.*24\\.04.*\\.AppImage$")) | .browser_download_url' | head -n1)

if [ -z "$ASSET_URL" ]; then
    echo "Error: Could not find Ubuntu 24.04 AppImage in release assets"
    exit 1
fi

echo "Found asset: $ASSET_URL"

# Extract ubuntu_version from the URL (e.g., "24.04_PR-8184")
UBUNTU_VERSION=$(echo "$ASSET_URL" | sed -n 's/.*ubuntu-\([^/]*\)\.AppImage$/\1/p')

if [ -z "$UBUNTU_VERSION" ]; then
    echo "Error: Could not extract Ubuntu version from asset URL"
    exit 1
fi

echo "Ubuntu version suffix: $UBUNTU_VERSION"

# Fetch and compute hash for x86_64-linux
echo "Fetching $ASSET_URL..."
HASH=$(nix-prefetch-url --type sha256 "$ASSET_URL")
HASH_SRI=$(nix hash convert --hash-algo sha256 --to sri "$HASH")

echo "Hash: $HASH_SRI"

# Update versions.json
jq --arg version "$LATEST_VERSION" \
   --arg ubuntu_version "$UBUNTU_VERSION" \
   --arg hash "$HASH_SRI" \
   '.["x86_64-linux"].version = $version | .["x86_64-linux"].ubuntu_version = $ubuntu_version | .["x86_64-linux"].hash = $hash' \
   "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp"

mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"

echo "Successfully updated to version $LATEST_VERSION"
echo "Updated $VERSIONS_FILE"
