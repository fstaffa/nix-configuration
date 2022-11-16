{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixgl.auto.nixGLNvidia
  ];
}
