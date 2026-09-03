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
          -- Hardened 2026-09-02: the AVR can also flap (CEC re-negotiation)
          -- *after* the mirror was already correctly applied, mid-session —
          -- not just during the initial boot-time enumeration race. When that
          -- happens HDMI-A-2 re-enumerates as a fresh, unmirrored, independent
          -- output with none of the fixes below applied, reproducing the same
          -- wrong-workspace/invisible-app symptoms live. So this now also
          -- reacts to HDMI-A-2 itself (re)appearing, not just DP-6. An
          -- in-flight guard prevents two near-simultaneous triggers (e.g. both
          -- monitors enumerating close together on a cold boot) from running
          -- overlapping hl.timer chains against each other. print(...) calls
          -- go to Hyprland's own log (hyprctl rollinglog /
          -- $XDG_RUNTIME_DIR/hypr/<sig>/hyprland.log), NOT journalctl — Hyprland
          -- is launched by sddm-helper outside systemd here, confirmed empty
          -- `journalctl _COMM=Hyprland` output.
          --
          -- Deliberately NOT adding a periodic re-assert watchdog: the two
          -- event-driven triggers (DP-6 added, HDMI-A-2 added) plus the
          -- monitor.removed logging below cover every plausible flap pattern
          -- (boot race, mid-session AVR flap, mid-session DP-6 drop/reconnect).
          -- A timer-based watchdog would add continuous overhead and a third
          -- independent trigger path to reason about for no additional
          -- coverage — revisit only if hyprland.log ever shows the AVR
          -- unmirrored without a corresponding add/remove event logged.
          --
          -- Bug found 2026-09-03: without a cooldown, this self-triggered
          -- forever, even with zero real AVR flapping. hl.monitor() only
          -- queues a rule change; Hyprland reconciles it one render frame
          -- later, which fires a genuine monitor.added for HDMI-A-2's own
          -- re-enable — but by then `applying` had already been reset to
          -- false (synchronously, right after issuing that same hl.monitor()
          -- call), so the guard didn't catch it and it kicked off a fresh
          -- run. Confirmed in hyprland.log: 12 back-to-back cycles on one
          -- boot, evenly spaced ~1s apart (matching this function's own two
          -- 500ms timers), each showing "Applying monitor rule for HDMI-A-2"
          -- (i.e. OUR disable call) immediately preceding "monitor.removed".
          -- Fix: hold the guard for a short cooldown after "done" so that
          -- delayed, self-generated event lands while still suppressed,
          -- instead of releasing the guard the instant we issue the last
          -- hl.monitor() call.
          local applying = false
          local function apply_avr_mirror(reason)
            if applying then
              print("apply_avr_mirror: already in progress, skipping duplicate trigger (" .. reason .. ")")
              return
            end
            applying = true
            print("apply_avr_mirror: starting (" .. reason .. ")")
            hl.timer(function()
              hl.monitor({ output = "HDMI-A-2", disabled = true })
              hl.timer(function()
                hl.monitor({ output = "HDMI-A-2", disabled = false, mirror = "DP-6" })
                -- waybar launches unconditionally on hyprland.start (see shared
                -- config), which races DP-6's enumeration on boots where HDMI-A-2
                -- (the AVR) comes up first — same underlying enumeration-order
                -- issue as the mirror above. Its hyprland/workspaces module does
                -- a one-time IPC sync on startup; if that happens before DP-6
                -- (and its workspaces) exist, it never recovers and shows no
                -- workspace buttons for the rest of the session. Restart it here,
                -- once the monitor topology has actually settled, to force a
                -- clean re-sync.
                --
                -- Match by full cmdline (`^waybar$`), not `pkill -x waybar`: Nix
                -- wraps the real binary and renames its comm to `.waybar-wrapped`,
                -- so `-x waybar` never matches anything — it silently no-ops and
                -- leaves a second instance running instead of replacing the first.
                -- The anchors also keep this from matching its own `bash -c` shell,
                -- whose cmdline is this whole string, not literally "waybar".
                hl.exec_cmd("bash -c 'pkill -f \"^waybar$\"; sleep 0.3; waybar'")
                print("apply_avr_mirror: done (" .. reason .. ")")
                -- Hold the guard a bit longer: the re-enable call just issued
                -- above hasn't been reconciled by Hyprland yet (that happens
                -- on the next frame), and its resulting monitor.added for
                -- HDMI-A-2 must find `applying` still true or it retriggers
                -- this whole function — see the 2026-09-03 note above.
                hl.timer(function()
                  applying = false
                end, { timeout = 500, type = "oneshot" })
              end, { timeout = 500, type = "oneshot" })
            end, { timeout = 500, type = "oneshot" })
          end

          if hl.get_monitor("DP-6") ~= nil then
            apply_avr_mirror("DP-6 already present at hyprland.start")
          end

          hl.on("monitor.added", function(m)
            print("monitor.added: " .. m.name)
            if m.name == "DP-6" or m.name == "HDMI-A-2" then
              apply_avr_mirror("monitor.added: " .. m.name)
            end
          end)

          hl.on("monitor.removed", function(m)
            print("monitor.removed: " .. m.name)
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
  # special:terminal/slack/brave are the special workspaces autostart apps
  # use (see shared/hyprland/default.nix and developer.nix exec_cmd calls) —
  # pinned to DP-6 for the same reason as workspaces 1-9 below: without this,
  # they can be created on HDMI-A-2 during the boot race window and become
  # invisible once the mirror is applied (mirrored monitors don't own
  # independent workspaces).
  wayland.windowManager.hyprland.settings.workspace_rule =
    (map (n: {
      workspace = toString n;
      monitor = "DP-6";
      default = true;
    }) (builtins.genList (i: i + 1) 9))
    ++ [
      {
        workspace = "special:terminal";
        monitor = "DP-6";
        default = true;
      }
      {
        workspace = "special:slack";
        monitor = "DP-6";
        default = true;
      }
      {
        workspace = "special:brave";
        monitor = "DP-6";
        default = true;
      }
      {
        workspace = "20";
        monitor = "desc:DENON Ltd. DENON-AVR";
        default = true;
      }
    ];
}
