{ config, lib, pkgs, ... }:

{
  # virtualization
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  users.users.mathematician314 = {
    extraGroups = [ "libvirtd" ];
    packages = with pkgs; [
      quickemu
    ];
  };
}
