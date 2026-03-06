{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./flatpak.nix
    ./hyprland.nix
    ./opensnitch.nix
    ./plasma.nix
    ./developer.nix
    ./full.nix
  ];

  # Display manager — shared across all desktop sessions
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ ];
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };


  # ergodox
  services.udev.packages = with pkgs; [ zsa-udev-rules ];

  # handle .local domain and mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  security.polkit.enable = true;
}
