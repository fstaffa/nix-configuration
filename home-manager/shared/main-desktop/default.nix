{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zoom-us
    brave
    slack
    postman
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
  ];

  services.syncthing.enable = true;
  services.opensnitch-ui.enable = true;
}
