{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.aws;
  iniFormat = pkgs.formats.ini { };

in {
  options.programs.aws = {
    enable = mkEnableOption "aws setup with bastions";
    accounts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          profile = mkOption { type = types.str; };
          createAdminProfile = mkOption {
            type = types.bool;
            default = false;
          };
          region = mkOption { type = types.str; };
          bastion = mkOption {
            type = types.submodule {
              options = {
                hostname = mkOption { type = types.str; };
                availabilityZone = mkOption { type = types.str; };
              };
            };
          };
          hosts = mkOption {
            type = types.attrsOf types.string;
            default = { };
          };
        };
      });
    };
  };

  config = let
    sshKey = "~/.ssh/id_rsa_yubikey.pub";
    convertAccount = (name: value:
      let
        usedProfile = if value.createAdminProfile then
          "${value.profile}@admin"
        else
          value.profile;

        proxyCommand = ''
          sh -c "aws ec2-instance-connect send-ssh-public-key --profile ${usedProfile} --instance-os-user ec2-user --ssh-public-key file://${sshKey} --instance-id %h;''
          + ''
            aws ssm start-session --profile ${usedProfile} --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"'';
        commonValues = {
          identityFile = sshKey;
          user = "ec2-user";
          inherit proxyCommand;
        };
        bastion = {
          name = "bastion-${name}";
          value = {
            host = "bastion-${name} rds-${name}*";
            hostname = value.bastion.hostname;
          } // commonValues;
        };
        hosts = mapAttrsToList (name: value: {
          name = name;
          value = {
            host = name;
            hostname = value;
          } // commonValues;
        }) value.hosts;
      in hosts ++ [ bastion ]);
    bastions =
      listToAttrs (flatten (mapAttrsToList convertAccount cfg.accounts));
  in mkIf cfg.enable {
    home.packages = [ pkgs.awscli2 pkgs.ssm-session-manager-plugin ];

    programs.ssh.matchBlocks = bastions;

    home.file."${config.home.homeDirectory}/.aws/config".source =
      iniFormat.generate "aws-config" ((mapAttrs' (name: value: {
        name = "profile ${value.profile}";
        value = { region = value.region; };
      }) cfg.accounts) // (mapAttrs' (name: value: {
        name = if value.createAdminProfile then
          "profile ${value.profile}@admin"
        else
          "profile ${value.profile}"; # noop for non admin
        value = { region = value.region; };
      }) cfg.accounts));
  };
}
