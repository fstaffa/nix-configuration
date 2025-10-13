#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/versions.json"

echo "Fetching latest Bruno release from GitHub..."
if [ -n "${GITHUB_TOKEN:-}" ]; then
    LATEST_VERSION=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/usebruno/bruno/releases/latest | jq -r '.tag_name' | sed 's/^v//')
else
    LATEST_VERSION=$(curl -s https://api.github.com/repos/usebruno/bruno/releases/latest | jq -r '.tag_name' | sed 's/^v//')
fi

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

# Fetch and compute hash for x86_64-linux
URL="https://github.com/usebruno/bruno/releases/download/v${LATEST_VERSION}/bruno_${LATEST_VERSION}_x86_64_linux.AppImage"
echo "Fetching $URL..."
HASH=$(nix-prefetch-url --type sha256 "$URL")
HASH_SRI=$(nix hash convert --hash-algo sha256 --to sri "$HASH")

echo "Hash: $HASH_SRI"

# Update versions.json
jq --arg version "$LATEST_VERSION" \
   --arg hash "$HASH_SRI" \
   '.["x86_64-linux"].version = $version | .["x86_64-linux"].hash = $hash' \
   "$VERSIONS_FILE" > "$VERSIONS_FILE.tmp"

mv "$VERSIONS_FILE.tmp" "$VERSIONS_FILE"

echo "Successfully updated to version $LATEST_VERSION"
echo "Updated $VERSIONS_FILE"
