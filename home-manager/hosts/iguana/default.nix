{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../shared/base-terminal
    ../../shared/terminal
    ../../modules/gpg-personal
    ../../shared/developer-terminal
    ../../shared/work
    ../../shared/emacs
    ../../shared/alacritty
    ../../shared/ghostty
    ./hyprland.nix
    ../../shared/plasma
    ../../shared/full-desktop
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
    stateVersion = "22.05";
  };

  myDesktop.plasma.enable = true;

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
