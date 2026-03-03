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

  services.syncthing.enable = true;
  programs.firefox = {
    enable = true;
    policies = {
      Certificates.ImportEnterpriseRoots = true;
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--disable-features=WaylandWpColorManagerV1"
    ];
  };

}
