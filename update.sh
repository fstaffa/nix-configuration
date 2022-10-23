#!/usr/bin/env sh

version=$1
for system in "Linux_x86_64" "Linux_i386" "Linux_arm64" "Darwin_x86_64" "Darwin_arm64"
do
    hash=$(nix-prefetch-url --type sha256 "https://ce-installation-binaries.s3.amazonaws.com/stskeygen/$version/stskeygen_${version}_$system.tar.gz")
    sed -i "s/\($system.*sha256 = \"\)\(.*\)\";/\1$hash\";/" flake.nix
done
