{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.projects;
  specificRdsConfig = { options = { host = mkOption { type = types.str; }; }; };
  rdsConfig = {
    options = {
      basePort = mkOption { type = types.int; };
      prd = mkOption { type = types.submodule specificRdsConfig; };
      stg = mkOption { type = types.submodule specificRdsConfig; };
    };
  };

  environments = {
    prd = 0;
    stg = 1;
  };
in {
  options = {
    projects = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      projects = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            #repositoryUrl = mkOption { type = types.str; };
            #folder = mkOption { type = types.str; };
            rds = mkOption { type = types.nullOr (types.submodule rdsConfig); };
            type = mkOption { type = types.enum [ "planning" ]; };
          };
        });
      };
    };
  };

  config = mkIf cfg.enable {
    programs.ssh.matchBlocks = (foldr (env: oldSet:
      (mapAttrs' (name: value: {
        name = "projects-${name}-${env}";
        value = hm.dag.entryBefore [ "rds-all" ] {
          host = "rds-${value.type}-${name}-${env}";
          localForwards = [{
            bind.port = value.rds.basePort + environments."${env}";
            host.address = value.rds."${env}".host;
            host.port = 5432;
          }];
        };
      }) cfg.projects) // oldSet) { } (attrNames environments)) //

      {
        rds-all = {
          host = "rds*";
          user = "ec2-user";
          extraOptions = { RequestTTY = "no"; };
        };
      };
  };
}
