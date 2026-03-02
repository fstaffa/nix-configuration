{ lib, config, ... }:
{
  options.myDesktop.hyprland.enable = lib.mkEnableOption "Hyprland";

  config = lib.mkIf config.myDesktop.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
