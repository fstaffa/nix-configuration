{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../../shared/ssh-server
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Allow root SSH access with the same key (needed for nix-anywhere deployments)
  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.mathematician314.openssh.authorizedKeys.keys;
}
