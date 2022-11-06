{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
      aspell
      ripgrep
      fd
      curl
      emacsGit
  ];
}
