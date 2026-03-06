{ pkgs, ... }:

{
  imports = [
    ../hyprland
  ];

  programs.firefox = {
    enable = true;
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
