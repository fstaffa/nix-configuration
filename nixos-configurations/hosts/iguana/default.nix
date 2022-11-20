{ config, lib, pkgs, ... }:

{
  imports =
    [
      ../../shared/common
      ../../shared/vm-host
      ./hardware-configuration.nix
    ];

  networking.hostName = "iguana";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  programs.steam = {
    enable = true;
  };

  programs.gnupg = {
    agent.enable = true;
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  users.users.mathematician314 = {
    isNormalUser = true;
    description = "mathematician314";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$6$rounds=65536$52ozQfxuGrmWZoNo$P8rggZJwwVLeShjLdNciD.EYmsHJ3N2W82drhToZnmzdl7PXC9JzpRzEHbrr6v.6/m8VQl4erGxmSvJ6aZG0T/";
    packages = with pkgs; [
      firefox
    ];
  };

  system.stateVersion = "22.05";
}
