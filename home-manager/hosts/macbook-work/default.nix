{ config, lib, pkgs, ... }:

{
  imports = [
    ../../shared/common
    ../../shared/work
    ../../shared/emacs
    ../../shared/terminal
    ../../modules/gpg-personal
  ];

  home = {
    username = "fstaffa";
    homeDirectory = "/Users/fstaffa";
    stateVersion = "22.05";
  };

  programs.gpg-personal = {
    enable = true;
    cardId = 4547547;
  };
}
