{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.gpg-personal;
  yubikey4Ids = [ 4547547 ];
  macGpgSettings =
    if pkgs.stdenv.isDarwin && (builtins.elem cfg.cardId yubikey4Ids) then {
      scdaemonSettings = {
        reader-port = "Yubico Yubikey";
        #debug-all = true;
        #debug-level="guru";
        disable-ccid = true;
        #shared-access = true;
        #log-file="/tmp/scd.log";
      };
    } else
      { };
in {
  options.programs.gpg-personal = {
    enable = mkEnableOption "personal gpg config with yubikey";
    cardId = mkOption { type = types.int; };
  };

  config = mkIf cfg.enable {
    home.file."${config.home.homeDirectory}/.ssh/id_rsa_yubikey.pub".text =
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr0l1uayq1GK/3xbEZw2I6dPkXYdH1Lq2+ZIZnHEgt1XkrKdyW0vFFKtevW+0eAJ5MIW6mvH7B+hcjyBrwKGxyKMZD3C3kNKaQw7VmlCNlgs6Njpobs54b3srbytKFMyReD5ydP02SU8Vb3dxD0ZTZYUUH0t+asZZmToQgEIP+m9F/4PgFU6eYRz437OOfh/bO2tYEjNwIUAqzK6lIjy2DNclIKlZ8cL2wh+sOUsNahp6cRniAs7BhjAWxD+DgVSK7NKLexM0LMlWRv8NKnuphdDmvOYrVvLCpaOD7JeJsVar18gB9RqfcPLP2R4rGPk3gcuiyE4mabIFTkXWCD1i7 cardno:${
        toString cfg.cardId
      }";
    programs.gpg = ({
      package = pkgs.gnupg22;
      enable = true;
      publicKeys = [{
        source = ./personal-key.txt;
        trust = "ultimate";
      }];
    } // macGpgSettings);

    programs.zsh.initExtra = if pkgs.stdenv.isDarwin then ''
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '' else
      "";
  };
}
