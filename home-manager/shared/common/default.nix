{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    tokei
    fnm
    ripgrep
    jq
    curl
    graphviz
    shellcheck
  ];

  programs = {
    home-manager.enable = true;
    gpg = {
      enable = true;
      publicKeys = [{
        source = ./gpg/personal-key.txt;
        trust = "ultimate";
      }];
    };
  };
}
