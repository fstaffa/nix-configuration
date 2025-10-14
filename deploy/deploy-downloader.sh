#!/usr/bin/env bash
set -euo pipefail

# Deploy script for downloader VM using nix-anywhere
# Usage: ./deploy-downloader.sh <target-ip> [ssh-key-path]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <target-ip> [ssh-key-path]"
    echo "Example: $0 192.168.1.100"
    echo "         $0 192.168.1.100 ~/.ssh/id_ed25519"
    exit 1
fi

TARGET_IP="$1"
SSH_KEY="${2:-$HOME/.ssh/id_ed25519}"

# Check if nix-anywhere is available
if ! command -v nix-anywhere &>/dev/null; then
    echo "nix-anywhere not found. Installing temporarily..."
    nix run github:nix-community/nixos-anywhere -- --help >/dev/null || {
        echo "Failed to run nix-anywhere"
        exit 1
    }
    NIX_ANYWHERE="nix run github:nix-community/nixos-anywhere --"
else
    NIX_ANYWHERE="nix-anywhere"
fi

# Get the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "================================================"
echo "Deploying downloader to $TARGET_IP"
echo "Using SSH key: $SSH_KEY"
echo "Repository: $REPO_ROOT"
echo "================================================"
echo ""
echo "WARNING: This will wipe all data on the target machine!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Deploy using nix-anywhere
$NIX_ANYWHERE \
    --flake "$REPO_ROOT#downloader" \
    --build-on-remote \
    mathematician314@"$TARGET_IP"

echo ""
echo "================================================"
echo "Deployment complete!"
echo "You can now SSH into the machine: ssh root@$TARGET_IP"
echo "================================================"
