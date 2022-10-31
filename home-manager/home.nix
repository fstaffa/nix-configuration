{ config, lib, pkgs, emacs-overlay, personal-packages, ... }:


let
  terminal-helpers = with pkgs;
    [
      tmux
      thefuck
      zoxide
      starship
      broot
      fzf
      tealdeer
      bat
      mcfly
    ];
  gui = with pkgs;
    if stdenv.isLinux then
      [
        flameshot
        xclip
      ]
    else [ ];
  emacs = with pkgs;
    [
      aspell
      ripgrep
      fd
      curl
      emacsGit
    ];
  work = with pkgs;
    [
      personal-packages.stskeygen
      awscli2
      ssm-session-manager-plugin
    ];
in
{
  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
  };

  home.packages = with pkgs; [
    tokei
    fnm
    ripgrep
    jq
    curl
    aria
    graphviz
    shellcheck

  ] ++ terminal-helpers ++ gui ++ work ++ emacs;

  programs.home-manager.enable = true;
  home.stateVersion = "22.05";
}
