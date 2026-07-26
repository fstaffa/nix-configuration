{ ... }:

{
  wayland.windowManager.hyprland.settings.monitor = [
    # Dell U3224KBA — 6K panel on DP-6, 2x scale → logical 3072x1728
    { output = "DP-6"; mode = "6144x3456@60"; position = "0x0"; scale = 2; }
    # DENON AVR receiver exposes an HDMI-CEC display with no real video output.
    # Mirror DP-6 instead of disabling — disabled = true powers down the HDMI link,
    # which also kills HDMI audio detection to the receiver.
    { output = "desc:DENON Ltd. DENON-AVR"; mirror = "DP-6"; }
    { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
  ];

  # Mirrored monitors still count as real outputs for workspace assignment,
  # so pin all workspaces to DP-6 to stop the DENON mirror from stealing one on startup.
  wayland.windowManager.hyprland.settings.workspace_rule = [
    { workspace = "r[1-9]"; monitor = "DP-6"; default = true; }
  ];
}
