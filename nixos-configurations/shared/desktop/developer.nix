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
      # xogot connect (godot remote deploy): device callback, debugger, file server
      9998
      6007
      6010
    ];
    networking.firewall.allowedUDPPorts = [
      # syncthing
      22000
      21027
      # xogot connect: device discovery
      9987
      9877
    ];
  };
}
