{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications
    burpsuite
    slack
    vlc

    keymapp

    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    vscode-fhs
    bruno-appimage
    bruno-cli

    # video
    obs-studio
    v4l-utils

    streamcontroller

    davinci-resolve-studio

    bubblewrap
    quickemu

    bambu-studio-appimage
  ];
}
