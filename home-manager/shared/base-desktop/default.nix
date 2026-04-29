{ pkgs, config, ... }:

{
  imports = [
    ../hyprland
  ];

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    policies = {
      Certificates.ImportEnterpriseRoots = true;
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--disable-features=WaylandWpColorManagerV1"
    ];
  };
}
