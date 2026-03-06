{ ... }:

{
  imports = [
    ../../shared/base-terminal
    ../../shared/terminal
    ../../modules/gpg-personal
    ../../shared/developer-terminal
    ../../shared/emacs
    ../../shared/alacritty
    ../../shared/ghostty
    ../../shared/developer-desktop
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
    stateVersion = "25.05";
  };

  programs.gpg-personal = {
    enable = true;
    cardId = 4157425;
  };
}
