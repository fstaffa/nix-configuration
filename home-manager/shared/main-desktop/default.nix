{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications
    brave
    burpsuite
    firefox
    slack
    vlc
    ghostty

    keymapp

    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    vscode-fhs

    # video
    obs-studio
    v4l-utils
    #video download helper
    vdhcoapp

    postman

    streamcontroller
    kdotool
  ];

  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  services.syncthing.enable = true;
  services.opensnitch-ui.enable = true;
}
