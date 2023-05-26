{ config, lib, pkgs, personal-packages, ... }:

let
  workZshPath = "${config.xdg.configHome}/zsh/work/work.zsh";
  workZshSecrets = "${config.xdg.configHome}/zsh/work/secrets.zsh";
  gitClone = { repositoryUrl, folder }:
    let destination = "${config.home.homeDirectory}/data/cimpress/${folder}";
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ${destination} ]; then
        $DRY_RUN_CMD git clone ${repositoryUrl} "${destination}"
      fi
    '';
in {

  imports = [ ../../modules/aws ../../modules/project ];
  home.packages = [ personal-packages.stskeygen pkgs.docker-compose ];

  home.file = { "${workZshPath}".source = ./work.zsh; };

  programs.aws = {
    enable = true;
    accounts = {
      planning = {
        profile = "logisticsquotingplanning";
        createAdminProfile = true;
        region = "eu-west-1";
        bastion = {
          hostname = "i-023acaf88ec144041";
          availabilityZone = "eu-west-1a";
        };
        hosts = { gitlab-runner-labe = "i-0ae2002a47d91f33d"; };
      };
      sapidus = {
        profile = "sapidus";
        createAdminProfile = true;
        region = "eu-west-1";
        bastion = {
          hostname = "i-0ed29dd7a58c495f0";
          availabilityZone = "eu-west-1a";
        };
      };
      praguematic = {
        profile = "praguematic";
        createAdminProfile = true;
        region = "eu-west-1";
        bastion = {
          hostname = "i-04951c408d649c7cb";
          availabilityZone = "eu-west-1a";
        };
      };
    };
  };

  programs.git.includes = [{
    condition = "gitdir:~/data/cimpress/";
    contents = {
      user = {
        name = "Filip Staffa";
        email = builtins.concatStringsSep "s" [ "f" "taffa@cimpre" "" ".com" ];
      };
    };
  }];

  programs.zsh.initExtra = ''
    # work files
    source "${workZshPath}"
    if [ -f "${workZshSecrets}" ]; then
      source "${workZshSecrets}"
    else
      echo "Missing work secrets file"
    fi
  '';

  projects = {
    enable = true;
    projects = {
      bastion-labe = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/infrastructure/bastion.git";
          folder = "bastion-labe";
        };
      };
      calendars-ui = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/calendars-ui.git";
          folder = "calendars-ui";
        };
      };
      ccm = {
        type = "planning";
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/ccm-next.git";
          folder = "ccm";
        };
        rds = {
          basePort = 15432;
          prd = { host = "ccm-prd.caweq0ojnzgj.eu-west-1.rds.amazonaws.com"; };
          stg = { host = "ccm-stg.caweq0ojnzgj.eu-west-1.rds.amazonaws.com"; };
        };
      };
      calendars = {
        type = "planning";
        rds = {
          basePort = 45432;
          prd = {
            host =
              "calendars-production.caweq0ojnzgj.eu-west-1.rds.amazonaws.com";
          };
          stg = {
            host = "calendars-staging.caweq0ojnzgj.eu-west-1.rds.amazonaws.com";
          };
        };
      };
      shipping-calculator = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/shipping-calculator.git";
          folder = "shipping-calculator";
        };
        type = "planning";
        rds = {
          basePort = 25432;
          prd = {
            host = "shipcalc-prd.caweq0ojnzgj.eu-west-1.rds.amazonaws.com";
          };
          stg = {
            host = "shipcalc-stg.caweq0ojnzgj.eu-west-1.rds.amazonaws.com";
          };
        };
      };
      configuration-service = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/Sapidus/configuration-service.git";
          folder = "configuration-service";
        };
      };
      deployment-sapidus = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/Sapidus/deployment.git";
          folder = "deployment-sapidus";
        };
      };
      logistics-configuration-ui = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/Sapidus/logistics-configuration-ui.git";
          folder = "logistics-configuration-ui";
        };
      };
      picky = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/pickups-aggregation-service.git";
          folder = "picky";
        };
      };
      planning-api = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/planning-api-service.git";
          folder = "planning-api";
        };
      };
      pup-scraper-service = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/pup-scraper-service.git";
          folder = "pup-scraper-service";
        };
      };
      quoter-publisher = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/Sapidus/Quoter-Publisher.git";
          folder = "quoter-publisher";
        };
      };
      shippping-options = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/shipping-options-service.git";
          folder = "shippping-options";
        };
      };
      shiprec = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/planning-event-processor.git";
          folder = "planning-event-processor";
        };
      };
      vltava-infrastructure = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/vltava-infrastructure.git";
          folder = "vltava-infrastructure";
        };
      };
      qpzip-comparison = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/labe/qpzip-comparison.git";
          folder = "qpzip-comparison";
        };
      };
      address-validation = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/address-validation-api.git";
          folder = "address-validation";
        };
      };
      address-validation-workflow-step = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/address-validation-workflow-step.git";
          folder = "address-validation-workflow-step";
        };
      };
      shipdate = {
        repository = {
          repositoryUrl = "git@gitlab.com:Cimpress-Technology/qp/ship-date.git";
          folder = "shipdate";
        };
      };
      pup-widget = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/pup-ui-widget.git";
          folder = "pup-widget";
        };
      };
      packer = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/packer-service.git";
          folder = "packer";
        };
      };
      packer-config = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/packer-config-service.git";
          folder = "packer-config";
        };
      };
      roadmap = {
        repository = {
          repositoryUrl = "git@gitlab.com:Cimpress-Technology/labe/roadmap.git";
          folder = "roadmap";
        };
      };
      exchange-rates = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/exchange-rates.git";
          folder = "exchange-rates";
        };
      };
      cimpress-react-components = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/internal-open-source/component-library/react-components.git";
          folder = "cimpress-react-components";
        };
      };
      boxman-service = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/boxman-service.git";
          folder = "boxman-service";
        };
      };
      ci-tools = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/praguematic/ci-tools.git";
          folder = "ci-tools";
        };
      };
    };
  };
}
