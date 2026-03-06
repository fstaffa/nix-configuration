{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myDesktop.developer.enable = lib.mkEnableOption "developer desktop";

  config = lib.mkIf config.myDesktop.developer.enable {
    networking.firewall.allowedTCPPorts = [
      # syncthing
      8384
      22000
      # expo go
      19323
    ];
    networking.firewall.allowedUDPPorts = [
      # syncthing
      22000
      21027
    ];
  };
}
