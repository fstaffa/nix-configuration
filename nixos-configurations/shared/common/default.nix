{ config, lib, pkgs, ... }:

{
# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.utf8";
    LC_IDENTIFICATION = "cs_CZ.utf8";
    LC_MEASUREMENT = "cs_CZ.utf8";
    LC_MONETARY = "cs_CZ.utf8";
    LC_NAME = "cs_CZ.utf8";
    LC_NUMERIC = "cs_CZ.utf8";
    LC_PAPER = "cs_CZ.utf8";
    LC_TELEPHONE = "cs_CZ.utf8";
    LC_TIME = "cs_CZ.utf8";
  };

  nixpkgs.config.allowUnfree = true;

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  programs.zsh = {
    enable = true;
  };
}
