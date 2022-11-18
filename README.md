
# Install vm

``` sh
sudo -i
export ROOT_DISK=/dev/sda
parted -a opt --script "${ROOT_DISK}" \
    mklabel gpt \
    mkpart primary fat32 0% 512MiB \
    mkpart primary 512MiB 100% \
    set 1 esp on \
    name 1 boot \
    set 2 lvm on \
    name 2 root
    
fdisk /dev/vda -l

mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2


mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

git clone https://github.com/fstaffa/nix-configuration.git /mnt/etc/nixos

nixos-install --root /mnt --flake /mnt/etc/nixos#vm-test
```
