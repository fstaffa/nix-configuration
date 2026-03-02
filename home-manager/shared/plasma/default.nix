{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.myDesktop.plasma.enable = lib.mkEnableOption "KDE Plasma home-manager integration";

  config = lib.mkIf config.myDesktop.plasma.enable {
    home.packages = with pkgs; [
      kdotool
    ];

    programs.firefox.nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };
}
