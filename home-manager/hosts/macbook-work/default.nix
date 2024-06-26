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

  home.packages = with pkgs; [ coreutils ];

  programs.gpg-personal = {
    enable = true;
    cardId = 23405290;
    # old keychain
    #cardId = 4547547;
    #cardId = 4256693;
  };

  # add vscode to the path
  home.sessionPath =
    [ "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ];
}
