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

  repositoryConfig = {
    options = {
      repositoryUrl = mkOption { type = types.str; };
      folder = mkOption { type = types.str; };
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
            rds = mkOption {
              type = types.nullOr (types.submodule rdsConfig);
              default = null;
            };
            type = mkOption { type = types.enum [ "planning" "praguematic" ]; };
            repository = mkOption {
              type = types.nullOr (types.submodule repositoryConfig);
              default = null;
            };
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
      }) (filterAttrs (name: value: value.rds != null) cfg.projects)) // oldSet)
      { } (attrNames environments)) //

      {
        rds-all = {
          host = "rds*";
          user = "ec2-user";
          extraOptions = { RequestTTY = "no"; };
        };
      };

    home.activation = (mapAttrs' (name: value:
      let
        destination =
          "${config.home.homeDirectory}/data/cimpress/${value.repository.folder}";
      in {
        name = "checkout-git-${name}";
        value = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d ${destination} ]; then
            $DRY_RUN_CMD git clone ${value.repository.repositoryUrl} "${destination}"
          fi
        '';

      }) (filterAttrs (name: value: value.repository != null) cfg.projects));

  };
}
