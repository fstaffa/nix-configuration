#!/usr/bin/env sh
DISK=$1

MNT=$(mktemp -d)
SWAPSIZE=4
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
 mkpart bpool 1GiB 5GiB \
 mkpart rpool 5GiB -$((SWAPSIZE + RESERVE))GB \
 mkpart swap  -$((SWAPSIZE + RESERVE))GB -"${RESERVE}"GB \
 mkpart BIOS 1MiB 2MiB \
 set 1 esp on \
 set 5 bios_grub on \
 set 5 legacy_boot on

 partprobe "${disk}"
 udevadm settle
}

for i in ${DISK}; do
   partition_disk "${i}"
done

# shellcheck disable=SC2046
zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O atime=off \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R "${MNT}" \
    bpool \
    $(for i in ${DISK}; do
       printf '%s ' "${i}-part2";
      done)

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
      printf '%s ' "${i}-part3";
     done)


zfs create \
 -o canmount=off \
 -o mountpoint=none \
rpool/nixos


for pool in $(jq -r 'keys | sort | join(" ")' < zfs-pools.json); do
    zfs create -o mountpoint=legacy "$pool"
    relative_pool_mount=$(jq -r ".\"$pool\".mount" < zfs-pools.json)
    absolute_pool_mount="${MNT}${relative_pool_mount}"
    if [ "$relative_pool_mount" != null ]; then
        mkdir -p "${absolute_pool_mount}"
        mount -t zfs "$pool" "${absolute_pool_mount}"
    fi;
done

zfs create -o mountpoint=none bpool/nixos
zfs create -o mountpoint=legacy bpool/nixos/root
mkdir "${MNT}"/boot
mount -t zfs bpool/nixos/root "${MNT}"/boot

# format and mount boot
for i in ${DISK}; do
    mkfs.vfat -n EFI "${i}"-part1
    mkdir -p "${MNT}"/boot/efis/"${i##*/}"-part1
    mount -t vfat -o iocharset=iso8859-1 "${i}"-part1 "${MNT}"/boot/efis/"${i##*/}"-part1
done
