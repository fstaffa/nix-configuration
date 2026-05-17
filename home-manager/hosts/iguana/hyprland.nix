{ ... }:

{
  wayland.windowManager.hyprland.settings.monitor = [
    # Dell U3224KBA — 6K panel on DP-6, 2x scale → logical 3072x1728
    { output = "DP-6"; mode = "6144x3456@60"; position = "0x0"; scale = 2; }
    { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
  ];
}
