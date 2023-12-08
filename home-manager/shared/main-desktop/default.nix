{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zoom-us
    brave
    firefox
    slack
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    vlc
  ];

  services.syncthing.enable = true;
  services.opensnitch-ui.enable = true;
}
