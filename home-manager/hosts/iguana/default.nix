{ config, lib, pkgs, ... }:

{
  imports = [
    ../../shared/common
    ../../shared/work
    ../../shared/emacs
    ../../shared/terminal
    ../../shared/alacritty
    ../../shared/ghostty
    ../../shared/main-desktop
    ../../modules/gpg-personal
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
    stateVersion = "22.05";
  };

  programs.gpg-personal = {
    enable = true;
    cardId = 4157425;
  };

  programs.zsh = {
    initExtra = ''
      VM_FOLDER=~/data/vm
      function vm {
        cd $VM_FOLDER
        find $VM_FOLDER -name '*.conf' | fzf | xargs -I {} quickemu --vm {} --display spice
        cd -
      }
    '';
  };

}
