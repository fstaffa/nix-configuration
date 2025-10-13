{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications
    brave
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

    postman

    streamcontroller
    kdotool

    davinci-resolve-studio

    quickemu
  ];

  services.syncthing.enable = true;
  services.opensnitch-ui.enable = true;

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };

}
