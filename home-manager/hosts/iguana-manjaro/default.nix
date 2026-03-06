{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../shared/base-terminal
    ../../shared/terminal
    ../../modules/gpg-personal
    ../../shared/developer-terminal
    ../../shared/work
    ../../shared/emacs
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
    stateVersion = "22.05";
  };

  programs.gpg-personal = {
    enable = true;
    cardId = 4157425;
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  programs.zsh = {
    initContent = ''
      VM_FOLDER=~/data/vm
      function vm {
        cd $VM_FOLDER
        find $VM_FOLDER -name '*.conf' | fzf | xargs -I {} quickemu --vm {} --display spice
        cd -
      }
    '';
  };

}
