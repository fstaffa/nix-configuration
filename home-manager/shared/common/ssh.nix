{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    extraOptionOverrides = {
      KeepAlive = "yes";
      IdentitiesOnly = "yes";
      IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
    };
    matchBlocks = {
      "komodo.local" = {
        user = "mathematician314";
        identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
      };
    };
  };
}
