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

  # TODO: remove once https://github.com/NixOS/nixpkgs/pull/496839 lands
  # libvirt ships a service unit hardcoding /usr/bin/sh which doesn't exist on NixOS
  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = [
    ""
    "${pkgs.bash}/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
  ];
}
