{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications
    slack
    vlc

    keymapp

    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    jetbrains.clion
    vscode-fhs
    bruno-appimage
    bruno-cli

    # video
    obs-studio
    v4l-utils

    streamcontroller

    bubblewrap
    quickemu

    bambu-studio-appimage
  ];
}
