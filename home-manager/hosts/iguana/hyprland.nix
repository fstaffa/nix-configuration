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

  # Mirrored monitors still count as real outputs for workspace assignment.
  # r[1-9] range selectors only match workspaces that already exist, so they can't
  # claim workspace "1" before it's created — Hyprland falls back to assigning it
  # to whichever monitor was detected first (often the DENON receiver). Use explicit
  # name-based rules instead, which apply persistently regardless of existence, and
  # give the DENON output its own default workspace well outside 1-9 so it never
  # grabs one of the real ones on startup.
  wayland.windowManager.hyprland.settings.workspace_rule =
    (map (n: {
      workspace = toString n;
      monitor = "DP-6";
      default = true;
    }) (builtins.genList (i: i + 1) 9))
    ++ [
      {
        workspace = "20";
        monitor = "desc:DENON Ltd. DENON-AVR";
        default = true;
      }
    ];
}
