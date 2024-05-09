{ config, lib, pkgs, pkgs-unstable, ... }:

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

  home.packages = with pkgs-unstable; [
    bind # dig package
    ncdu
    tealdeer
    thefuck
    tmux
  ];
}
