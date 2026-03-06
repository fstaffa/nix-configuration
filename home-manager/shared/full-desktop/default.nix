{ pkgs, ... }:

{
  imports = [
    ../developer-desktop
    ../hyprland/full.nix
  ];

  home.packages = with pkgs; [
    # video
    obs-studio
    v4l-utils

    streamcontroller

    davinci-resolve-studio

    quickemu

    bambu-studio-appimage
  ];
}
