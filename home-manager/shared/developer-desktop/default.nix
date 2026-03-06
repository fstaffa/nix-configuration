{ pkgs, ... }:

{
  imports = [
    ../base-desktop
    ../hyprland/developer.nix
  ];

  services.syncthing.enable = true;

  home.packages = with pkgs; [
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

    burpsuite

    bubblewrap
  ];
}
