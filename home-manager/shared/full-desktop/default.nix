{ pkgs, ... }:

{
  imports = [
    ../developer-desktop
    ../hyprland/full.nix
  ];

  services.easyeffects.enable = true;

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

    quickemu

    bambu-studio-appimage

    prismlauncher
  ];
}
