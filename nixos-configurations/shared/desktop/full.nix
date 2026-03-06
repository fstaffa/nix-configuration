{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myDesktop.full.enable = lib.mkEnableOption "full desktop";

  config = lib.mkIf config.myDesktop.full.enable {
    myDesktop.developer.enable = true;

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    programs.gamescope.enable = true;

    # obs virtual camera
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

    services.ollama = {
      enable = false;
      package = [ pkgs.ollama-rocm ];
      rocmOverrideGfx = "12.0.1";
    };
    services.open-webui = {
      enable = false;
      port = 11200;
    };

    environment.systemPackages = with pkgs; [
      rocmPackages.amdsmi
      vulkan-tools
    ];
  };
}
