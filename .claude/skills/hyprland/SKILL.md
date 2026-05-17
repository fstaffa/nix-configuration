---
name: hyprland
description: |
  Hyprland configuration manager for NixOS + home-manager (Lua mode). Use PROACTIVELY when:
  - Adding, modifying, or removing keybinds, window rules, monitors, animations, env vars, or startup apps
  - Troubleshooting Hyprland config errors (deprecated options, nil dispatchers, syntax issues)
  - Migrating config after a Hyprland version upgrade
  - Changing visual theming (borders, gaps, blur, colors, decorations, waybar styling)
  - Anything touching wayland.windowManager.hyprland settings
  Triggers: hyprland, keybind, window rule, monitor, animation, waybar, hyprctl, compositor, tiling
---

# Hyprland Configuration Skill

Manage Hyprland configuration through the NixOS home-manager module using `configType = "lua"`.

## Critical: Check version and wiki docs

Hyprland's Lua API changes between versions. Before making changes:

1. **Check the installed version:**
   ```sh
   hyprctl version | head -1
   # or: nix eval --raw ".#nixosConfigurations.iguana.pkgs.hyprland.version"
   ```

2. **Consult the wiki source for the correct API:** The rendered wiki (wiki.hypr.land) is JavaScript-heavy and often fails with WebFetch. Instead, fetch raw markdown from the GitHub repository:
   ```
   https://raw.githubusercontent.com/hyprwm/hyprland-wiki/main/content/Configuring/Basics/<page>.md
   ```
   Key pages:
   - `Variables.md` — config sections (general, decoration, input, misc, etc.)
   - `Binds.md` — hl.bind() API, flags, submaps
   - `Dispatchers.md` — hl.dsp.* function names
   - `Window-Rules.md` — hl.window_rule() syntax
   - `Monitors.md` — hl.monitor() fields
   - `Autostart.md` — hl.on("hyprland.start", ...) and hl.exec_cmd()

   Advanced pages at `content/Configuring/Advanced and Cool/`:
   - `Animations.md` — hl.curve() and hl.animation()
   - `Environment-variables.md` — hl.env()

3. **If a dispatcher causes a nil error**, the name likely changed. Check `Dispatchers.md` for the current Lua name.

## Config file locations

```
home-manager/shared/hyprland/default.nix    — base config (all hosts)
home-manager/shared/hyprland/developer.nix  — developer overlay (work apps)
home-manager/shared/hyprland/full.nix       — gaming overlay (Steam)
home-manager/hosts/iguana/hyprland.nix      — host-specific (monitor)
```

## Home-manager module: Nix → Lua translation

`configType = "lua"` means each key in `settings` becomes an `hl.<key>(...)` call. List values generate one call per element.

### Config sections → hl.config({...})

```nix
settings.config = {
  general = { border_size = 3; gaps_in = 3; gaps_out = 6; };
  decoration = { dim_inactive = true; blur = { enabled = true; size = 8; }; };
  input = { kb_layout = "us,cz"; repeat_rate = 50; };
  misc = { disable_hyprland_logo = true; };
};
```

### Keybinds → hl.bind(keys, dispatcher[, flags])

Use `_args` lists with `lib.generators.mkLuaInline` for dispatchers:

```nix
let mkLuaInline = lib.generators.mkLuaInline; in
{
  settings.bind = [
    { _args = [ "SUPER + Return" (mkLuaInline ''hl.dsp.exec_cmd("alacritty")'') ]; }
    { _args = [ "SUPER + SHIFT + Q" (mkLuaInline "hl.dsp.window.kill()") ]; }
    { _args = [ "SUPER + H" (mkLuaInline ''hl.dsp.focus({ direction = "l" })'') ]; }
    # With flags:
    { _args = [ "XF86AudioMute" (mkLuaInline ''hl.dsp.exec_cmd("pamixer -t")'') { locked = true; } ]; }
    { _args = [ "XF86AudioRaiseVolume" (mkLuaInline ''hl.dsp.exec_cmd("pamixer -i 5")'') { repeating = true; } ]; }
    { _args = [ "SUPER + mouse:272" (mkLuaInline "hl.dsp.window.drag()") { mouse = true; } ]; }
  ];
}
```

**Bind flags** (third _args element, optional table):
- `{ locked = true; }` — works with input inhibitor (screen lock)
- `{ repeating = true; }` — hold to repeat (replaces `binde`)
- `{ mouse = true; }` — mouse bind (replaces `bindm`)
- `{ release = true; }` — trigger on key release

### Window rules → hl.window_rule({...})

```nix
settings.window_rule = [
  { name = "float-mpv"; match.class = "^mpv$"; float = true; size = "960 540"; center = true; }
  { name = "slack-ws"; match.class = "^Slack$"; workspace = "special:slack silent"; }
  { name = "maximize-satty"; match.class = "^com\\.gabm\\.satty$"; float = true; maximize = true; }
  { name = "pip-pin"; match.title = "^Picture.in.Picture$"; float = true; pin = true; }
];
```

Common window_rule fields: `float`, `tile`, `pin`, `maximize`, `fullscreen`, `size`, `center`, `move`, `workspace` (append `silent` to suppress focus), `opacity`, `border_size`, `rounding`, `no_blur`, `no_shadow`.

### Monitors → hl.monitor({...})

```nix
settings.monitor = [
  { output = "DP-6"; mode = "6144x3456@60"; position = "0x0"; scale = 2; }
  { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
];
```

### Environment variables → hl.env(key, value)

```nix
settings.env = [
  { _args = [ "XCURSOR_SIZE" "24" ]; }
  { _args = [ "QT_QPA_PLATFORM" "wayland" ]; }
];
```

### Startup apps → hl.on("hyprland.start", fn)

```nix
settings.on = [
  {
    _args = [
      "hyprland.start"
      (mkLuaInline ''function()
        hl.exec_cmd("waybar")
        hl.exec_cmd("firefox")
      end'')
    ];
  }
];
```

Note: use a **list** `on = [...]` so multiple modules can each add their own handler via NixOS module merging.

### Animations → hl.curve() + hl.animation()

```nix
settings.curve = [
  { _args = [ "easeOutQuint" (mkLuaInline "{ type = \"bezier\", points = {{0.23,1},{0.32,1}} }") ]; }
];
settings.animation = [
  { leaf = "windows"; enabled = true; speed = 4.79; bezier = "easeOutQuint"; }
  { leaf = "windowsIn"; enabled = true; speed = 4.1; bezier = "easeOutQuint"; style = "popin 87%"; }
];
```

### Submaps

Use the `submaps` option (separate from `settings`):

```nix
wayland.windowManager.hyprland.submaps.resize = {
  settings.bind = [
    { _args = [ "H" (mkLuaInline ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'') { repeating = true; } ]; }
    { _args = [ "escape" (mkLuaInline ''hl.dsp.submap("reset")'') ]; }
  ];
};
```

## Common dispatcher names (Lua)

`hl.dsp.focus()` is polymorphic — it handles direction focus, workspace focus, and window focus depending on the argument key.

| Action | Lua dispatcher |
|--------|---------------|
| Run command | `hl.dsp.exec_cmd("cmd")` |
| Kill window | `hl.dsp.window.kill()` |
| Move focus (direction) | `hl.dsp.focus({ direction = "l" })` |
| Focus workspace | `hl.dsp.focus({ workspace = "1" })` |
| Focus window by class | `hl.dsp.focus({ window = "class:ClassName" })` |
| Move window (direction) | `hl.dsp.window.move({ direction = "l" })` |
| Move to workspace | `hl.dsp.window.move({ workspace = "1" })` |
| Resize (keyboard) | `hl.dsp.window.resize({ x = 20, y = 0, relative = true })` |
| Resize (mouse bind) | `hl.dsp.window.resize()` |
| Drag window (mouse) | `hl.dsp.window.drag()` |
| Toggle float | `hl.dsp.window.float({ action = "toggle" })` |
| Fullscreen | `hl.dsp.window.fullscreen({ mode = 1 })` |
| Toggle special ws | `hl.dsp.workspace.toggle_special("name")` |
| Enter submap | `hl.dsp.submap("name")` |
| Layout message | `hl.dsp.layout("swapwithmaster")` |

If a dispatcher doesn't exist or returns nil, check Dispatchers.md in the wiki repo for the current API.

## When skill information is wrong or outdated

Hyprland's Lua API evolves rapidly. If anything in this skill produces an error or doesn't work as described:

1. **Report it to the user explicitly** — say which part of the skill was wrong (e.g., "the dispatcher name `hl.dsp.layout_msg` no longer exists")
2. **Find the correct API** — fetch the relevant wiki page from the GitHub raw source and look up the current name/syntax
3. **Propose a fix** — show the corrected Nix/Lua code
4. **Suggest updating this skill** — tell the user "this skill has stale information, would you like me to update it?" so future sessions benefit from the correction

The skill is only as useful as it is accurate. Stale dispatcher names, removed config options, or changed syntax are expected as Hyprland evolves — always verify against the current wiki when something doesn't work.

## Required base settings

These must be set in `default.nix` for Lua mode to work:

```nix
wayland.windowManager.hyprland = {
  enable = true;
  package = null;        # use system Hyprland from NixOS module
  portalPackage = null;
  configType = "lua";
};
```

## Companion programs (separate modules)

These are NOT configured through `wayland.windowManager.hyprland.settings` — they have their own home-manager options:

- `services.hypridle` — idle/sleep behavior
- `programs.hyprlock` — lock screen
- `services.hyprpaper` — wallpaper

## Verification workflow

```sh
# Build test (Nix eval + lua generation)
make test.homemanager

# Inspect generated output
cat ~/.config/hypr/hyprland.lua

# Apply
home-manager switch --flake "."

# Reload (same config format) or restart session (switching formats)
hyprctl reload
```

## Module merging behavior

The three layers (default.nix, developer.nix, full.nix) plus host overrides all merge via NixOS module system:
- **Lists** (bind, window_rule, monitor, env, on, curve, animation) — concatenated
- **Attrsets** (config) — deep-merged
- Host overrides take precedence for conflicting scalar values

This means each layer can add its own binds, window rules, and startup commands without conflicts.
