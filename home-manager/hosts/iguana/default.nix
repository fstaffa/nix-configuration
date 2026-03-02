{ config, lib, pkgs, ... }:

{
  imports = [
    ../../shared/common
    ../../shared/work
    ../../shared/emacs
    ../../shared/terminal
    ../../shared/alacritty
    ../../shared/ghostty
    ../../shared/hyprland
    ../../shared/main-desktop
    ../../shared/plasma
    ../../modules/gpg-personal
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
    stateVersion = "22.05";
  };

  myDesktop.plasma.enable = true;
  myDesktop.hyprland.enable = true;

  programs.gpg-personal = {
    enable = true;
    cardId = 4157425;
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      VM_FOLDER=~/data/vm
      function vm {
        cd $VM_FOLDER
        find $VM_FOLDER -name '*.conf' | fzf | xargs -I {} quickemu --vm {} --display spice
        cd -
      }
    '';
  };

}
