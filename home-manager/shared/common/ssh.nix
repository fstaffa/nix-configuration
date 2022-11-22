{ config, lib, pkgs, ... }:

{
  home.file."${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub".source = ./id_rsa_yubikey.pub;
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    extraOptionOverrides = {
      KeepAlive = "yes";
      IdentitiesOnly = "yes";
      IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
    };
    matchBlocks = { };
  };
}
