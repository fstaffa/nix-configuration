{ config, lib, pkgs, personal-packages, ... }:

let workZshPath = "${config.xdg.configHome}/zsh/work/work.zsh";
    workZshSecrets = "${config.xdg.configHome}/zsh/work/secrets.zsh";
in {
  home.packages = with pkgs;
    [
      personal-packages.stskeygen
      awscli2
      ssm-session-manager-plugin
    ];

  home.file = {
    "${workZshPath}".source = ./work.zsh;
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/data/cimpress/";
      contents = {
        user = {
          name = "Filip Staffa";
          email = builtins.concatStringsSep "s" ["f" "taffa@cimpre" "" "" ".com"];
        };
      };
    }
  ];

  programs.zsh.initExtra = ''
    # work files
    source "${workZshPath}"
    if [ -f "${workZshSecrets}" ]; then
      source "${workZshSecrets}"
    else
      echo "Missing work secrets file"
    fi
    '';
}
