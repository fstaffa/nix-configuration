{ lib, ... }:

let
  mkLuaInline = lib.generators.mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings.monitor = [
    # Dell U3224KBA — 6K panel, 2x scale → logical 3072x1728. Matched by
    # `desc:` (EDID description), not connector name: the panel is behind an
    # MST hub, and MST connector numbering is NOT stable across boots —
    # confirmed 2026-09-13, kernel logged "DM_MST: Differing MST start on
    # aconnector" and the panel enumerated as DP-3 instead of its usual DP-6,
    # which broke every DP-6-hardcoded rule below (see sddm-boot-denon.md,
    # "Bug 5"). `desc:` is immune to this because it matches on EDID content,
    # not connector identity.
    {
      output = "desc:Dell Inc. DELL U3224KBA 6M9C9P3";
      mode = "6144x3456@60";
      position = "0x0";
      scale = 2;
    }
    # DENON AVR receiver exposes an HDMI-CEC display with no real video output.
    # Mirror the Dell panel instead of disabling — disabled = true powers down
    # the HDMI link, which also kills HDMI audio detection to the receiver.
    #
    # Previously observed `desc:` silently failing to apply here (mirrorOf
    # stays "none") and Hyprland treating the AVR as a real, independent
    # 1920x1080 output instead. Unity (and presumably other engines) then
    # picks it as the "primary device" for fullscreen, resizes to the Dell
    # panel's logical resolution instead, and crashes with SIGSEGV inside
    # RADV (Liftoff Micro Drones, confirmed).
    #
    # Source review 2026-09-13: `CMonitor::setMirror()` resolves its argument
    # through the exact same `configString`/selector-matching path as every
    # other `desc:`-capable field, so `desc:` is not actually rejected by
    # `mirror` specifically — the earlier failure was very likely the same
    # connector-enumeration-order race described below (the target not yet
    # existing in the live monitor list when the rule applied), not a
    # `desc:`-specific limitation. Left unverified/untested either way: the
    # `monitor.added` handler below sidesteps the question entirely by
    # resolving the Dell panel's *current* connector name via `desc:` lookup
    # at runtime and passing that resolved literal `.name` into `mirror`.
    #
    # This static rule alone is NOT sufficient: monitor rules apply in
    # connector-enumeration order, not config order. On boots where HDMI-A-2
    # (the AVR) enumerates before the Dell panel, this rule runs while the
    # panel doesn't exist yet, so the mirror target can't resolve and silently
    # falls back to a normal, independent output — reintroducing the crash.
    # See the `monitor.added` handler below, which re-applies the mirror once
    # the panel is confirmed present, regardless of connect order.
    #
    # Upstream bug report: https://github.com/hyprwm/Hyprland/discussions/15695
    # Once fixed upstream, try removing the `on.hyprland.start` workaround
    # below and confirm a plain `mirror = "desc:..."` resolves correctly
    # across reboots before deleting it.
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
          --
          -- Bug found 2026-09-13: the Dell panel is behind an MST hub, and
          -- MST connector numbering is NOT stable across boots — it enumerated
          -- as DP-3 instead of DP-6 on one boot (kernel logged "DM_MST:
          -- Differing MST start on aconnector"), which broke the hardcoded
          -- "DP-6" mirror target below and every DP-6-hardcoded rule
          -- elsewhere in this file. Resolve the panel by `desc:` (EDID
          -- content, immune to connector renumbering) at the point of use and
          -- use its *resolved* `.name` as the mirror target. (Whether `mirror`
          -- itself could take a `desc:` selector directly is actually
          -- unverified either way — see the static rule above — but resolving
          -- dynamically here sidesteps the question and removes the
          -- hardcoded connector name regardless.)
          local DELL_DESC = "Dell Inc. DELL U3224KBA 6M9C9P3"
          local function find_dell()
            return hl.get_monitor("desc:" .. DELL_DESC)
          end

          local applying = false
          local function apply_avr_mirror(reason)
            if applying then
              print("apply_avr_mirror: already in progress, skipping duplicate trigger (" .. reason .. ")")
              return
            end
            local dell = find_dell()
            if dell == nil then
              print("apply_avr_mirror: aborting, Dell panel not present yet (" .. reason .. ")")
              return
            end
            local dell_name = dell.name
            applying = true
            print("apply_avr_mirror: starting, mirroring " .. dell_name .. " (" .. reason .. ")")
            hl.timer(function()
              hl.monitor({ output = "HDMI-A-2", disabled = true })
              hl.timer(function()
                hl.monitor({ output = "HDMI-A-2", disabled = false, mirror = dell_name })
                -- waybar launches unconditionally on hyprland.start (see shared
                -- config), which races the Dell panel's enumeration on boots
                -- where HDMI-A-2 (the AVR) comes up first — same underlying
                -- enumeration-order issue as the mirror above. Its
                -- hyprland/workspaces module does a one-time IPC sync on
                -- startup; if that happens before the panel (and its
                -- workspaces) exist, it never recovers and shows no
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

          if find_dell() ~= nil then
            apply_avr_mirror("Dell panel already present at hyprland.start")
          end

          hl.on("monitor.added", function(m)
            print("monitor.added: " .. m.name .. " (" .. m.description .. ")")
            if m.description == DELL_DESC or m.name == "HDMI-A-2" then
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
  # pinned to the Dell panel for the same reason as workspaces 1-9 below:
  # without this, they can be created on HDMI-A-2 during the boot race window
  # and become invisible once the mirror is applied (mirrored monitors don't
  # own independent workspaces).
  #
  # Matched by `desc:` rather than connector name (e.g. "DP-6") — the Dell
  # panel is behind an MST hub whose connector numbering is NOT stable across
  # boots (confirmed 2026-09-13: it enumerated as DP-3 on one boot instead of
  # its usual DP-6, which broke every hardcoded-name rule here). `desc:`
  # matches on EDID content instead, so it survives connector renumbering. See
  # the `on.hyprland.start` handler above for the same fix applied to the AVR
  # mirror target, which resolves the connector name dynamically instead
  # (whether `mirror` itself accepts `desc:` directly is unverified — see the
  # comment on the static monitor rule above).
  wayland.windowManager.hyprland.settings.workspace_rule =
    (map (n: {
      workspace = toString n;
      monitor = "desc:Dell Inc. DELL U3224KBA 6M9C9P3";
      default = true;
    }) (builtins.genList (i: i + 1) 9))
    ++ [
      {
        workspace = "special:terminal";
        monitor = "desc:Dell Inc. DELL U3224KBA 6M9C9P3";
        default = true;
      }
      {
        workspace = "special:slack";
        monitor = "desc:Dell Inc. DELL U3224KBA 6M9C9P3";
        default = true;
      }
      {
        workspace = "special:brave";
        monitor = "desc:Dell Inc. DELL U3224KBA 6M9C9P3";
        default = true;
      }
      {
        workspace = "20";
        monitor = "desc:DENON Ltd. DENON-AVR";
        default = true;
      }
    ];
}
