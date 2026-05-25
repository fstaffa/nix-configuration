{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  nix.enable = true;

  environment.systemPackages = with pkgs; [
    ghostty-bin
    emacs-macport
  ];

  security.pki.certificateFiles = [
    ../../../common/certificates/ca.pem
    ../../../common/certificates/home-arpa-ca.crt
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;

  system.primaryUser = "fstaffa";

  system.defaults.dock.autohide = true;
  system.defaults.dock.autohide-time-modifier = 0.1;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.show-recents = false;

  # disable Sonoma's click-wallpaper-to-show-desktop
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.finder.FXPreferredViewStyle = "Nlsv";
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.ShowStatusBar = true;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

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
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;

  #disable long press to accent
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  #corresponding sliders KeyRepeat: 120, 90, 60, 30, 12, 6, 2
  system.defaults.NSGlobalDomain.KeyRepeat = null;
  #corresponding sliders InitialKeyRepeat: 120, 94, 68, 35, 25, 15
  system.defaults.NSGlobalDomain.InitialKeyRepeat = null;

  # Disable built-in macOS keyboard shortcuts that conflict with other tools.
  # IDs come from `defaults read com.apple.symbolichotkeys`.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys =
    let
      off = { enabled = false; };
    in
    {
      # Screenshots — owned by CleanShot
      "28" = off; # cmd+shift+3 (screen to file)
      "29" = off; # cmd+shift+ctrl+3 (screen to clipboard)
      "30" = off; # cmd+shift+4 (selection to file)
      "31" = off; # cmd+shift+ctrl+4 (selection to clipboard)
      "184" = off; # cmd+shift+5 (screenshot UI)

      # Spotlight
      "64" = off; # cmd+space
      "65" = off; # cmd+opt+space (Finder search)

      # Mission Control / Spaces
      "32" = off; # ctrl+up (Mission Control)
      "33" = off; # ctrl+down (App windows)
      "34" = off; # ctrl+opt+up
      "36" = off; # ctrl+opt+down
      "79" = off; # ctrl+left (move space left)
      "80" = off; # ctrl+shift+left
      "81" = off; # ctrl+right (move space right)
      "82" = off; # ctrl+shift+right
      "118" = off; # ctrl+1 (switch to space 1)
      "119" = off; # ctrl+2
      "120" = off; # ctrl+3
      "121" = off; # ctrl+4
      "122" = off; # ctrl+5

      # Dictation (double-tap fn)
      "164" = off;
    };

  system.stateVersion = 6;
}
