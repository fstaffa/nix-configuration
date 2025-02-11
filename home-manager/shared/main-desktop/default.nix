{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications
    brave
    burpsuite
    firefox
    slack
    vlc

    keymapp

    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider
    vscode-fhs

    # video
    obs-studio
    v4l-utils
    #video download helper
    vdhcoapp

    postman

    streamcontroller
    kdotool
  ];

  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  services.syncthing.enable = true;
  services.opensnitch-ui.enable = true;

  systemd.user.services.squeezelite = {
    Unit = {
      Description = "User-level Squeezelite Service";
      After = [ "pipewire.service" "network-online.target" ];
    };

    Service = {
      ExecStart =
        "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n roon-target -s 192.168.10.208";
      Restart = "on-failure";
      RestartSec = "10";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
}
