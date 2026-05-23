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
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
      "komodo.local" = {
        User = "mathematician314";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub";
      };
      "github.com" = {
        ControlMaster = "auto";
        ControlPersist = "10m";
      };
      "gitlab.com" = {
        ControlMaster = "auto";
        ControlPersist = "10m";
      };
    };
  };
}
