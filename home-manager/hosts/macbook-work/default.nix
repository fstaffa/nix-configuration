{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/gpg-personal
    ../../shared/common
    ../../shared/terminal
    ../../shared/work
    ../../shared/emacs
  ];

  home = {
    username = "fstaffa";
    homeDirectory = "/Users/fstaffa";
    stateVersion = "22.05";
  };

  programs.gpg-personal = {
    enable = true;
    cardId = 4547547;
    #cardId = 4256693;
  };
}
