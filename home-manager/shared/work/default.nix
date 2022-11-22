{ config, lib, pkgs, personal-packages, ... }:

let
  workZshPath = "${config.xdg.configHome}/zsh/work/work.zsh";
  workZshSecrets = "${config.xdg.configHome}/zsh/work/secrets.zsh";
  gitClone = { repositoryUrl, folder }:
    let destination = "${config.home.homeDirectory}/data/cimpress/${folder}"; in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ${destination} ]; then
        $DRY_RUN_CMD git clone ${repositoryUrl} "${destination}"
      fi
    '';
in
{
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
          email = builtins.concatStringsSep "s" [ "f" "taffa@cimpre" "" ".com" ];
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

  home.activation = {
    "checkout bastion labe" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/labe/infrastructure/bastion.git";
        folder = "bastion-labe";
      };
    "checkout calendars ui" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/labe/calendars-ui.git";
        folder = "calendars-ui";
      };
    "checkout ccm" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/vltava-squad/ccm-next.git";
        folder = "ccm";
      };
    "checkout configuration service" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/Sapidus/configuration-service.git";
        folder = "configuration-service";
      };
    "checkout deployment sapidus" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/Sapidus/deployment.git";
        folder = "deployment-sapidus";
      };
    "checkout logistics configuration-ui" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/Sapidus/logistics-configuration-ui.git";
        folder = "logistics-configuration-ui";
      };
    "checkout picky" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/vltava-squad/pickups-aggregation-service.git";
        folder = "picky";
      };
    "checkout planning api" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/planning-api-service.git";
        folder = "planning-api";
      };
    "checkout pup scraper-service" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/pup-scraper-service.git";
        folder = "pup-scraper-service";
      };
    "checkout quoter publisher" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/Sapidus/Quoter-Publisher.git";
        folder = "quoter-publisher";
      };
    "checkout shipping calculator" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/labe/shipping-calculator.git";
        folder = "shipping-calculator";
      };
    "checkout shippping options" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/shipping-options-service.git";
        folder = "shippping-options";
      };
    "checkout shiprec" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/qp/shipping-recommendation.git";
        folder = "shiprec";
      };
    "checkout vltava infrastructure" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/vltava-squad/vltava-infrastructure.git";
        folder = "vltava-infrastructure";
      };
    "checkout qpzip comparison" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/labe/qpzip-comparison.git";
        folder = "qpzip-comparison";
      };
    "checkout address validation" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/address-validation-api.git";
        folder = "address-validation";
      };
    "checkout address validation-workflow-step" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/address-validation-workflow-step.git";
        folder = "address-validation-workflow-step";
      };
    "checkout shipdate" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/qp/ship-date.git";
        folder = "shipdate";
      };
    "checkout pup widget" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/pup-ui-widget.git";
        folder = "pup-widget";
      };
    "checkout packer" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/packer-service.git";
        folder = "packer";
      };
    "checkout packer config" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/packer-config-service.git";
        folder = "packer-config";
      };
    "checkout roadmap" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/labe/roadmap.git";
        folder = "roadmap";
      };
    "checkout exchange rates" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/exchange-rates.git";
        folder = "exchange-rates";
      };
    "checkout cimpress react-components" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/internal-open-source/component-library/react-components.git";
        folder = "cimpress-react-components";
      };
    "checkout boxman service" = gitClone
      {
        repositoryUrl = "git@gitlab.com:Cimpress-Technology/praguematic/boxman-service.git";
        folder = "boxman-service";
      };
  };
}
