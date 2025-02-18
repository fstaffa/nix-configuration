{ config, lib, pkgs, ... }:

{
  imports = [ ../../shared/ssh-server ];

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  programs.

}
