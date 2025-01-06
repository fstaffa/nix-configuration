{ config, lib, pkgs, ... }:

{
  # virtualization
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  users.users.mathematician314 = {
    extraGroups = [ "libvirtd" "docker" ];
    packages = with pkgs; [ ];
  };

  # podman
  virtualisation.podman = {
    enable = false;
    dockerSocket.enable = true;
  };

  # docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
}
