{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.myDesktop.plasma.enable = lib.mkEnableOption "KDE Plasma 6";

  config = lib.mkIf config.myDesktop.plasma.enable {
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [ elisa ];
    programs.kdeconnect.enable = true;
  };
}
