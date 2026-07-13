{ config, lib, pkgs, ... }:
{
  options.myDesktop.fpv.enable = lib.mkEnableOption "FPV drone tools";

  config = lib.mkIf config.myDesktop.fpv.enable {
    services.udev.packages = with pkgs; [
      edgetx
    ];

    users.users.mathematician314.extraGroups = [ "dialout" ];
  };
}
