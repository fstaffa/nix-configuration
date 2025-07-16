{ config, lib, pkgs, ... }:

{
  imports = [ ./flatpak.nix ./squeezelite.nix ];

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

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamescope.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ ];
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

  services.openiscsi = {
    enable = true;
    name = "iqn.2000-01.com.nixos:iguana";
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

  #synthcing firewall
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  # obs virtual camera
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;
}
