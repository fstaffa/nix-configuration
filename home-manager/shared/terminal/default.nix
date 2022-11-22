{ config, lib, pkgs, ... }:

{
  programs = {
    aria2.enable = true;
    bat.enable = true;
    broot = {
      enable = true;
      enableZshIntegration = true;
    };
    mcfly = {
      enable = true;
      fuzzySearchFactor = 2;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      options = [ "--cmd j" ];
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.packages = with pkgs;
    [
      tmux
      thefuck
      fzf
      tealdeer
    ];
}
