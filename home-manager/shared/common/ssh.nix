{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    extraOptionOverrides = {
      KeepAlive = "yes";
      IdentitiesOnly = "yes";
      IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
      ControlPath =
        "${config.home.homeDirectory}/.ssh/sockets/control-%r@%h:%p";
    };
    matchBlocks = {
      "komodo.local" = {
        user = "mathematician314";
        identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
      };
    };
  };
}
