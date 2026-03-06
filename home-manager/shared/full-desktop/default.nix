{ pkgs, ... }:

{
  imports = [
    ../developer-desktop
    ../hyprland/full.nix
  ];

  home.packages = with pkgs; [
    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    burpsuite

    # video
    obs-studio
    v4l-utils

    streamcontroller

    davinci-resolve-studio

    quickemu

    bambu-studio-appimage
  ];
}
