{ config, lib, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "89d095c5";
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
}
