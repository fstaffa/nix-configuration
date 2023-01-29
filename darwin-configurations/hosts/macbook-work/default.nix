{ config, lib, pkgs, ... }:

{
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.dock.autohide = true;

  networking.hostName = "raptor";
  networking.localHostName = "raptor";

  homebrew = {
    enable = true;

  }
}
