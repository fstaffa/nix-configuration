{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./flatpak.nix
    ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

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

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  programs.steam = {
    enable = true;
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services.opensnitch = {
    enable = false;
    settings = {
      DefaultAction = "deny";
      DefaultDuration = "15m";
    };
  };
}
