{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.pki.certificateFiles = [ ../../../common/certificates/ca.pem ];

  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.autohide-time-modifier = 0.1;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.show-recents = false;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.finder.FXPreferredViewStyle = "Nlsv";
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;

  networking.hostName = "raptor";
  networking.localHostName = "raptor";

  # trackpad direction
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # smart keyboard
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

  #disable long press to accent
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  #corresponding sliders KeyRepeat: 120, 90, 60, 30, 12, 6, 2
  system.defaults.NSGlobalDomain.KeyRepeat = null;
  #corresponding sliders InitialKeyRepeat: 120, 94, 68, 35, 25, 15
  system.defaults.NSGlobalDomain.InitialKeyRepeat = null;
}
