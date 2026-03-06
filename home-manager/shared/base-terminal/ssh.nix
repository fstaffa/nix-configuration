{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file.".ssh/sockets/keep" = {
    text = "";
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraOptionOverrides = {
      KeepAlive = "yes";
      IdentitiesOnly = "yes";
      IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
      ControlPath = "${config.home.homeDirectory}/.ssh/sockets/control-%r@%h:%p";
    };
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
      "komodo.local" = {
        user = "mathematician314";
        identityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
      };
      "github.com" = {
        controlMaster = "auto";
        controlPersist = "10m";
      };
      "gitlab.com" = {
        controlMaster = "auto";
        controlPersist = "10m";
      };
    };
  };
}
