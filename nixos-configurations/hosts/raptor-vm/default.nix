{ lib, ... }:

{
  imports = [
    ../../shared/common
    ../../shared/desktop
    ../../shared/vm
    ../../shared/ssh-server
    ./hardware-configuration.nix
  ];

  # shared/common hardcodes GRUB + ZFS for iguana; override for this VM
  boot.loader.grub.enable = lib.mkForce false;
  boot.initrd.supportedFilesystems = lib.mkForce [ ];

  networking.hostName = "raptor-vm";

  myDesktop.developer.enable = true;

  nix.gc.options = "--delete-older-than 14d";

  system.stateVersion = "25.05";
}
