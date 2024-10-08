{ config, lib, pkgs, ... }:

{
  imports =
    [ ../../shared/common ../../shared/vm ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [ elisa okular ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.filip = {
    isNormalUser = true;
    description = "filip";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "";
    packages = with pkgs; [ firefox kate ];
  };

  system.stateVersion = "22.05";
}
