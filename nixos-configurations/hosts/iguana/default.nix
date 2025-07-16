{ config, lib, pkgs, ... }:

{
  imports = [
    ../../shared/common
    ../../shared/desktop
    ../../shared/vm-host
    ./hardware-configuration.nix
    ./zfs.nix
  ];

  networking.hostName = "iguana";

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa ];
  programs.kdeconnect.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

  users.users.mathematician314 = {
    uid = 1000;
    isNormalUser = true;
    description = "mathematician314";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword =
      "$6$rounds=65536$52ozQfxuGrmWZoNo$P8rggZJwwVLeShjLdNciD.EYmsHJ3N2W82drhToZnmzdl7PXC9JzpRzEHbrr6v.6/m8VQl4erGxmSvJ6aZG0T/";
  };

  system.stateVersion = "22.05";
}
