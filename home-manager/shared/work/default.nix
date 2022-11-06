{ config, lib, pkgs, personal-packages, ... }:

{
  home.packages = with pkgs;
    [
      personal-packages.stskeygen
      awscli2
      ssm-session-manager-plugin
    ];
}
