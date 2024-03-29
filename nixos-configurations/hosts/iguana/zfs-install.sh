#!/usr/bin/env sh
set -e

if [ $# -ne 1 ]; then
    echo "Requires one argument, name of disk"
    exit 1
fi
DISK=$1

MNT=$(mktemp -d)
SWAPSIZE=8
RESERVE=1

#enable nix flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

if ! command -v git; then nix-env -f '<nixpkgs>' -iA git; fi
if ! command -v jq;  then nix-env -f '<nixpkgs>' -iA jq; fi
if ! command -v partprobe;  then nix-env -f '<nixpkgs>' -iA parted; fi

partition_disk () {
 disk="${1}"
 blkdiscard -f "${disk}"

 parted --script --align=optimal  "${disk}" -- \
 mklabel gpt \
 mkpart EFI 2MiB 1GiB \
 mkpart rpool 1GiB -$((SWAPSIZE + RESERVE))GB \
 mkpart swap  -$((SWAPSIZE + RESERVE))GB -"${RESERVE}"GB \
 mkpart BIOS 1MiB 2MiB \
 set 1 esp on \
 set 4 bios_grub on \
 set 4 legacy_boot on

 partprobe "${disk}"
 udevadm settle
}

for i in ${DISK}; do
   partition_disk "${i}"
done

mkswap "/dev/disk/by-partlabel/swap"

# shellcheck disable=SC2046
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R "${MNT}" \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O atime=off \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool \
   $(for i in ${DISK}; do
      printf '%s ' "${i}-part2";
     done)


zfs create \
 -o canmount=off \
 -o mountpoint=none \
rpool/nixos

#create pools
for pool in $(jq -r 'keys | sort | join(" ")' < zfs-pools.json); do
    zfs create -o mountpoint=legacy "$pool"
done

#create temporary mountpoints and mount
for pool in $(jq -r 'to_entries | map(select(.value | has ("mount"))) | sort_by(.value.mount) | .[].key' < zfs-pools.json); do
    relative_pool_mount=$(jq -r ".\"$pool\".mount" < zfs-pools.json)
    absolute_pool_mount="${MNT}${relative_pool_mount}"
    if [ "$relative_pool_mount" != null ]; then
        mkdir -p "${absolute_pool_mount}"
        mount -t zfs "$pool" "${absolute_pool_mount}"
    fi;
done

zfs create -o refreservation=200G -o mountpoint=none rpool/reserved

mkdir "${MNT}"/boot

# format and mount boot
for i in ${DISK}; do
    mkfs.vfat -n EFI "${i}"-part1
    mkdir -p "${MNT}"/boot
    mount -t vfat -o iocharset=iso8859-1 "${i}"-part1 "${MNT}"/boot
done

mkdir -p "${MNT}"/etc

git clone --depth 1 https://github.com/fstaffa/nix-configuration.git "${MNT}"/etc/nixos

cd "${MNT}/etc/nixos"
