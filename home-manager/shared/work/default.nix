{ config, lib, pkgs, personal-packages, ... }:

let
  workZshPath = "${config.xdg.configHome}/zsh/work/work.zsh";
  workZshSecrets = "${config.xdg.configHome}/zsh/work/secrets.zsh";
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
          hostname = "i-0168143d6bc2cc748";
          availabilityZone = "eu-west-1a";
        };
        hosts = { gitlab-runner-labe = "i-0f0582ed3374ca67b"; };
      };
      sapidus = {
        profile = "sapidus";
        createAdminProfile = true;
        region = "eu-west-1";
        bastion = {
          hostname = "i-0dc0a28fa2312b347";
          availabilityZone = "eu-west-1a";
        };
      };
      praguematic = {
        profile = "praguematic";
        createAdminProfile = true;
        region = "eu-west-1";
        bastion = {
          hostname = "i-0fefd4f0a1ae8b237";
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
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/infrastructure/bastion.git";
          folder = "bastion-labe";
        };
      };
      logistics-microservices-alignment = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/initiatives/engineering-alignment/microservices.git";
          folder = "logistics-microservices-alignment";
        };
      };
      calendars-ui = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/calendars-ui.git";
          folder = "calendars-ui";
        };
      };
      ccm = {
        type = "planning";
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/ccm-next.git";
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
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/shipping-calculator.git";
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
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/pickups-aggregation-service.git";
          folder = "picky";
        };
      };
      planning-api = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/planning-api-service.git";
          folder = "planning-api";
        };
      };
      planning-event-processor = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/planning-event-processor.git";
          folder = "planning-event-processor";
        };
        type = "planning";
        rds = {
          basePort = 55432;
          prd = { host = "pep-prd.caweq0ojnzgj.eu-west-1.rds.amazonaws.com"; };
          stg = { host = "pep-stg.caweq0ojnzgj.eu-west-1.rds.amazonaws.com"; };
        };
      };
      quoter-publisher = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/Sapidus/Quoter-Publisher.git";
          folder = "quoter-publisher";
        };
      };
      renovate-bot = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/renovate-bot.git";
          folder = "renovate-bot";
        };
      };
      renovate-test-project-nodejs = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/renovate-test-project-nodejs.git";
          folder = "renovate-test-project-nodejs";
        };
      };
      renovate-test-project-dotnet = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/renovate-test-project-dotnet.git";
          folder = "renovate-test-project-dotnet";
        };
      };
      shippping-options = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/shipping-options-service.git";
          folder = "shippping-options";
        };
      };
      vltava-infrastructure = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/vltava-infrastructure.git";
          folder = "vltava-infrastructure";
        };
      };
      packer = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/packer-service.git";
          folder = "packer";
        };
      };
      packer-config = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/packer-config-service.git";
          folder = "packer-config";
        };
      };
      packer-ui = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/praguematic/packer-ui.git";
          folder = "packer-ui";
        };
      };
      roadmap = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/roadmap.git";
          folder = "roadmap";
        };
      };
      exchange-rates = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/exchange-rates.git";
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
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/praguematic/boxman-service.git";
          folder = "boxman-service";
        };
        type = "praguematic";
        rds = {
          basePort = 45432;
          prd = {
            host =
              "db-boxman-production.ckibexf9dpta.eu-west-1.rds.amazonaws.com";
          };
          stg = {
            host = "db-boxman-staging.ckibexf9dpta.eu-west-1.rds.amazonaws.com";
          };
        };
      };
      boxman-ui = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/praguematic/boxman-ui.git";
          folder = "boxman-ui";
        };
      };
      ci-tools = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/praguematic/ci-tools.git";
          folder = "ci-tools";
        };
      };
      ci-cd-components = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/infrastructure/ci-cd-components.git";
          folder = "ci-cd-components";
        };
      };
      dojo-ts-template = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/dojo/dojo-ts-template.git";
          folder = "dojo-ts-template";
        };
      };
      dojo-cs-template = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/dojo/csharp-template.git";
          folder = "dojo-cs-template";
        };
      };
      gitlab-configuration = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/infrastructure/gitlab-configuration.git";
          folder = "gitlab-configuration";
        };
      };
      planning-v2 = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v2/tms/planning-v2.git";
          folder = "planning-v2";
        };
      };
      rate-zone-maps-migrator = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/tools/ratezonemapsmigrator.git";
          folder = "rate-zone-maps-migrator";
        };
      };
      react-platform-components = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/internal-open-source/component-library/react-platform-components.git";
          folder = "react-platform-components";
        };
      };
      documentation = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/documentation.git";
          folder = "documentation";
        };
      };
      security-documentation = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/security/documentation.git";
          folder = "security-documentation";
        };
      };
      shiprec-ui = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/praguematic/shiprec-ui.git";
          folder = "shiprec-ui";
        };
      };
      tms-security-checker = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/security/tms-security-checker.git";
          folder = "tms-security-checker";
        };
      };
      transit-data-comparer = {
        repository = {
          repositoryUrl =
            "git@gitlab.com:Cimpress-Technology/fulfillment/logistics/logistics-v1/labe/tools/TransitDataComparer.git";
          folder = "transit-data-comparer";
        };
      };
    };
  };
}
