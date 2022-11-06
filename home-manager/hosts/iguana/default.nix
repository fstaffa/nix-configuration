{ config, lib, pkgs, ... }:

{
  imports = [
    ../../shared/work
    ../../shared/emacs
    ../../shared/terminal
    ../../shared/common
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
  };

  home.stateVersion = "22.05";
}
