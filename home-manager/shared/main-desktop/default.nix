{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zoom-us
    slack
    postman
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
  ];
}
