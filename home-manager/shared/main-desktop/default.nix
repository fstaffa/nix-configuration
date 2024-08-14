{ config, lib, pkgs, pkgs-unstable, ... }:

let
  stable-packages = with pkgs; [
    # Applications
    brave
    burpsuite
    firefox
    slack
    vlc

  ];
  unstable-packages = with pkgs-unstable; [
    keymapp

    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    vscode-fhs

    # video
    obs-studio
    v4l-utils
  ];
in {
  home.packages = stable-packages ++ unstable-packages;
  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  services.syncthing.enable = true;
  services.opensnitch-ui.enable = true;
}
