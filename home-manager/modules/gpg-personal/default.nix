{ config, lib, pkgs, ... }:
with lib;
let
  x = 0;
  cfg = config.programs.gpg-personal;
  macGpgSettings = if pkgs.stdenv.isDarwin then {
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQjmOGBCm6yXHbUvSOjsns1uQX8yyrzgmhCrUkB9HZbZE7/C2LeNckL0EU3PwBPzmS5FszYBgnMVezpu+xMFfmt+jA4lzmidFU9cbY4vvw7lEYboHStZNu/H/uC8/HPkRvIOS9XyYCLj7z/cM2XyjLKP+Ky1L4zn/Lq6F2S1pY/VGzzuvVzHoocYX4hh2dDPwPTGpedPRgr0ko0xg2j+hfmy2L4Rh7yxn5l7wyBVPVMh1PPURbo9PwaHOrgtGj94dgVQhizr0c9qrFU4Sij3F2SebYcZWrgAoyRVCoQue9oxyOIrZQw+GE5Q75bmslxBMpvjzcDF4XhYWzzFyQZ129 cardno:${
        toString cfg.cardId
      }";
    programs.gpg = ({
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
