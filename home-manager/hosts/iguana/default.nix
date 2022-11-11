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
    stateVersion = "22.05";
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
