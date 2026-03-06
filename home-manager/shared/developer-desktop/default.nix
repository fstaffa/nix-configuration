{ pkgs, lib, ... }:

{
  imports = [
    ../base-desktop
    ../hyprland/developer.nix
  ];

  services.syncthing.enable = true;

  home.packages =
    with pkgs;
    [
      slack
      vlc

      keymapp

      # Development
      vscode-fhs
      bruno-cli

      bubblewrap
    ]
    ++ lib.optionals stdenv.hostPlatform.isx86_64 [
      bruno-appimage
    ];
}
