{ config, lib, pkgs, ... }:

{
  # systemd.user.services.squeezelite = {
  #   enable = true;
  #   after = [ "pipewire.service" "sound.target" "network-online.target" ];
  #   description = "User-level Squeezelite Service in nixos configuration";

  #   serviceConfig = {
  #     ExecStart =
  #       "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n roon-target";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [ 3483 9000 9090 ];
  networking.firewall.allowedUDPPorts = [ 3483 ];
}
