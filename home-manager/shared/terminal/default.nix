{ config, lib, pkgs, ... }:

{

  programs.aria2.enable = true;
  programs.bat.enable = true;
  programs.mcfly.enable = true;
  programs.mcfly.fuzzySearchFactor = 2;

  programs.zoxide.enable = true;

  home.packages = with pkgs;
    [
      tmux
      thefuck
      starship
      broot
      fzf
      tealdeer
    ];
}
