{ config, lib, pkgs, ... }:

{

  home.programs = with pkgs; [
        flameshot
        xclip
      ];
}
