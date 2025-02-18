{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../shared/ssh-server
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
