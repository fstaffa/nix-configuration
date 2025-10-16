{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../shared/ssh-server
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Networking configuration
  networking.hostName = "downloader";
  networking.useDHCP = lib.mkDefault true;

  # Enable QEMU guest agent for Proxmox integration
  services.qemuGuest.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    tidal-dl-ng
  ];

  # System state version
  system.stateVersion = "24.05";
}
