# General

### Apply home manager

```sh
nix-shell -p home-manager
nix-shell -p git
cd $(mktemp -d)
git clone --depth 1 https://github.com/fstaffa/nix-configuration.git
home-manager switch --flake "."
```

### Try gpg

after install, gpg has problem using yubikey and this unblocks it

```sh
echo "test" | gpg --clearsign
```

### Chezmoi install

```sh
chezmoi init --source ~/.local/share/chezmoi git@github.com:fstaffa/dotfiles.git
```

### Refresh fonts

```sh
fc-cache -f -v
```

on macos

```sh
open ~/.local/share/fonts
```

open Font Book and drag the fonts inside it

# Install macos

```sh
cd $(mktemp -d)
git clone https://github.com/fstaffa/nix-configuration.git
cd nix-configuration
nix develop --extra-experimental-features 'nix-command flakes'
home-manager switch --flake ".#raptor" --extra-experimental-features "flakes nix-command"


nix build ".#darwinConfigurations.raptor.system"

printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

./result/sw/bin/darwin-rebuild switch --flake ".#raptor"

nix run nix-darwin -- switch --flake .#raptor
```

## Download apps

```sh
cd $(mktemp -d)
curl --location "https://github.com/syncthing/syncthing-macos/releases/download/v1.23.5-1/Syncthing-1.23.5-1.dmg" --output syncthing.dmg
curl --location "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US" --output Firefox.dmg
curl --location "https://dl.pstmn.io/download/latest/osx_arm64" --output Postman.zip
curl --location "https://laptop-updates.brave.com/latest/osx" --output Brave.dmg
curl --location "https://zoom.us/client/5.15.2.19786/zoomusInstallerFull.pkg?archType=arm64" --output zoom.pkg
open .
```

## Settings

- touch id in settings -> touch id
- login to office and install - https://www.office.com/
- install slack

## Update MacOs

Add following to the end of /etc/zshrc

```sh
# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
```

## Doom emacs + vterm

There is a problem building vterm with nix gcc, following operations need to be done to build it correctly:

``` sh
export CC=clang CXX=clang++
doom sync && doom build
```

then open vterm in emacs and it will compile


# Linux with zfs

```sh
git clone --depth 1 https://github.com/fstaffa/nix-configuration.git
cd nix-configuration/nixos-configurations/hosts/iguana

find /dev/disk/by-id -not -name "*-part*"
source zfs-install.sh $DISK

nixos-install --root "${MNT}" --flake "${MNT}/etc/nixos#iguana"

umount -Rl "${MNT}"
zpool export -a
swapoff -a
reboot
```

# Install vm

```sh
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

# After install

- Firefox install bitwarden, enable sync, in ublock origin -> settings enable cloud sync and download settings
