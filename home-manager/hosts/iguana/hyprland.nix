{ lib, ... }:

let
  mkLuaInline = lib.generators.mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings.monitor = [
    # Dell U3224KBA — 6K panel on DP-6, 2x scale → logical 3072x1728
    { output = "DP-6"; mode = "6144x3456@60"; position = "0x0"; scale = 2; }
    # DENON AVR receiver exposes an HDMI-CEC display with no real video output.
    # Mirror DP-6 instead of disabling — disabled = true powers down the HDMI link,
    # which also kills HDMI audio detection to the receiver.
    #
    # Must use the physical output name here, not a `desc:` matcher — with
    # `desc:` the mirror silently fails to apply (mirrorOf stays "none") and
    # Hyprland treats the AVR as a real, independent 1920x1080 output. Unity
    # (and presumably other engines) then picks it as the "primary device"
    # for fullscreen, resizes to DP-6's logical resolution instead, and
    # crashes with SIGSEGV inside RADV (Liftoff Micro Drones, confirmed).
    #
    # This static rule alone is NOT sufficient: monitor rules apply in
    # connector-enumeration order, not config order. On boots where HDMI-A-2
    # (the AVR) enumerates before DP-6, this rule runs while DP-6 doesn't
    # exist yet, so the mirror target can't resolve and silently falls back
    # to a normal, independent output — reintroducing the crash. See the
    # `monitor.added` handler below, which re-applies the mirror once DP-6
    # is confirmed present, regardless of connect order.
    #
    # Upstream bug report: https://github.com/hyprwm/Hyprland/discussions/15695
    # Once fixed upstream, try removing the `on.hyprland.start` workaround
    # below and confirm `mirror = "DP-6"` alone resolves correctly across
    # reboots before deleting it.
    { output = "HDMI-A-2"; mirror = "DP-6"; }
    { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
  ];

  wayland.windowManager.hyprland.settings.on = [
    {
      _args = [
        "hyprland.start"
        (mkLuaInline ''function()
          -- Workaround for https://github.com/hyprwm/Hyprland/discussions/15695
          -- Re-apply the AVR mirror whenever DP-6 becomes available, since
          -- monitor rules apply in connector-enumeration order, not config
          -- order — if HDMI-A-2 enumerates first, the static rule above
          -- can't resolve "DP-6" as a mirror target yet, and it comes up as
          -- a normal, independent output instead.
          --
          -- Setting `mirror` on an ALREADY-ACTIVE, non-mirrored monitor is
          -- also a no-op — Hyprland only resolves a mirror target during an
          -- activation transition (disabled -> enabled), not from an
          -- in-place property update. So this must disable HDMI-A-2, then
          -- re-enable it with the mirror set, to force that transition.
          --
          -- The disable and re-enable calls must NOT run back-to-back in the
          -- same function: Hyprland only queues a pending monitor rule change
          -- on hl.monitor() and reconciles it once per rendered frame. Two
          -- calls with no frame in between get coalesced into one pending
          -- change, which behaves like a single plain `mirror = "DP-6"` call
          -- and silently fails the same way. hl.timer() forces a real delay
          -- so each call lands in its own frame.
          local function apply_avr_mirror()
            hl.timer(function()
              hl.monitor({ output = "HDMI-A-2", disabled = true })
              hl.timer(function()
                hl.monitor({ output = "HDMI-A-2", disabled = false, mirror = "DP-6" })
              end, { timeout = 500, type = "oneshot" })
            end, { timeout = 500, type = "oneshot" })
          end

          if hl.get_monitor("DP-6") ~= nil then
            apply_avr_mirror()
          end

          hl.on("monitor.added", function(m)
            if m.name == "DP-6" then
              apply_avr_mirror()
            end
          end)
        end'')
      ];
    }
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
