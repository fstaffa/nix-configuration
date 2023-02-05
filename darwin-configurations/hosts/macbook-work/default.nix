{ config, lib, pkgs, ... }:

{
  services.nix-daemon.enable = true;
  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.dock.autohide = true;

  networking.hostName = "raptor";
  networking.localHostName = "raptor";

  # trackpad direction
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
}
