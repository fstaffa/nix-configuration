{
  pkgs,
  config,
  lib,
  ...
}:
let
  terminal = "alacritty";
  mkLuaInline = lib.generators.mkLuaInline;

  screenrecGif = pkgs.writeShellApplication {
    name = "screenrec-gif";
    runtimeInputs = with pkgs; [
      wl-screenrec
      slurp
      ffmpeg
      gifsicle
      libnotify
    ];
    text = ''
      PID_FILE="/tmp/wl-screenrec.pid"
      TMP_PATH_FILE="/tmp/wl-screenrec.tmppath"

      if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        # Stop: signal recorder — background subshell waits and converts
        kill -INT "$(cat "$PID_FILE")"
        exit 0
      fi

      REGION="$(slurp)" || exit 1

      OUTPUT_DIR="$HOME/Videos/recordings"
      OUTPUT="$OUTPUT_DIR/rec_$(date +%Y%m%d_%H%M%S).gif"
      TMP_MP4="/tmp/screenrec-$(date +%s).mp4"
      mkdir -p "$OUTPUT_DIR"
      echo "$TMP_MP4" > "$TMP_PATH_FILE"

      notify-send "Screen Recorder" "Recording started — press \$mod+R to stop"

      {
        wl-screenrec -g "$REGION" -f "$TMP_MP4" &
        echo $! > "$PID_FILE"
        wait "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$PID_FILE" "$TMP_PATH_FILE"

        notify-send "Screen Recorder" "Converting to GIF..."

        RAW_GIF="''${TMP_MP4%.mp4}-raw.gif"
        ffmpeg -i "$TMP_MP4" \
          -filter_complex "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=floyd_steinberg" \
          "$RAW_GIF" -y 2>/dev/null
        gifsicle -O3 --lossy=65 -o "$OUTPUT" "$RAW_GIF"
        rm -f "$TMP_MP4" "$RAW_GIF"
        notify-send "Screen Recorder" "GIF saved: $(basename "$OUTPUT")"
      } &>/dev/null &
      disown
    '';
  };
in
{
  home.packages = with pkgs; [
    xarchiver
    thunar
    thunar-volman
    thunar-archive-plugin
    xfconf # settings persistence for Thunar outside XFCE
    gvfs # trash, remote mounts, MTP (D-Bus activated)
    tumbler # thumbnail previews (D-Bus activated)
    libnotify
    rofi-power-menu
    grimblast
    satty
    cliphist
    wl-clipboard
    wlsunset
    hyprshutdown
    hyprpolkitagent
    playerctl
    pamixer
    pavucontrol
    screenrecGif
  ];

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  services.swaync.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        # Intentionally no idle timeout for locking — screen locks only on explicit
        # command ($mod+Escape) or before sleep.
      };
      listener = [
        {
          timeout = 600; # 10 minutes — turn off display only, no lock
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          color = "rgba(1e1e2eff)";
        }
      ];
      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
          outer_color = "rgba(89b4faee)";
          inner_color = "rgba(1e1e2eff)";
          font_color = "rgba(cdd6f4ff)";
          placeholder_text = "Password...";
          fail_color = "rgba(f38ba8ee)";
          check_color = "rgba(a6e3a1ee)";
        }
      ];
      label = [
        {
          text = "$TIME";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgba(cdd6f4ff)";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "color:0x1e1e2e" ];
      wallpaper = [ ",color:0x1e1e2e" ];
    };
  };

  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font 14";
    terminal = terminal;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    extraConfig = {
      show-icons = true;
      icon-theme = "Adwaita";
      modi = "drun,calc,emoji,run";
      display-drun = " Apps";
      display-run = " Run";
      display-calc = " Calc";
      display-emoji = " Emoji";
      drun-display-format = "{name}";
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          bg = mkLiteral "rgba(30, 30, 46, 0.80)";
          bg-sel = mkLiteral "#313244";
          fg = mkLiteral "#cdd6f4";
          fg-accent = mkLiteral "#89b4fa";
          fg-muted = mkLiteral "#6c7086";
          fg-urgent = mkLiteral "#f38ba8";
          background-color = mkLiteral "@bg";
          text-color = mkLiteral "@fg";
          border-color = mkLiteral "@fg-accent";
        };
        "window" = {
          width = mkLiteral "600px";
          border = mkLiteral "2px solid";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "8px";
        };
        "element selected" = {
          background-color = mkLiteral "@bg-sel";
          text-color = mkLiteral "@fg-accent";
        };
        "element-text" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
        };
        "inputbar" = {
          padding = mkLiteral "8px";
          border-radius = mkLiteral "4px";
        };
        "prompt" = {
          text-color = mkLiteral "@fg-accent";
        };
        "entry" = {
          placeholder = "Search...";
          placeholder-color = mkLiteral "@fg-muted";
        };
        "listview" = {
          lines = 8;
          padding = mkLiteral "4px 0";
        };
      };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "tray"
          "custom/notification"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        pulseaudio = {
          format = "󰕾 {volume}%";
          format-muted = "󰝟 muted";
          on-click = "pamixer -t";
          on-click-right = "pavucontrol";
          tooltip-format = "{desc} — {volume}%";
        };

        network = {
          format-ethernet = "󰈀 {ipaddr}";
          format-wifi = "󰤨 {essid}";
          format-disconnected = "󰤭 disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          interval = 5;
        };

        cpu = {
          format = "󰻠 {usage}%";
          interval = 5;
          tooltip = false;
        };

        memory = {
          format = "󰍛 {percentage}%";
          interval = 5;
          tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{} {icon}";
          format-icons = {
            notification = "󰂚";
            none = "󰂜";
            dnd-notification = "󰂛";
            dnd-none = "󰂛";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt>{calendar}</tt>";
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
      }
      window#waybar {
        background: rgba(26, 27, 38, 0.9);
        color: #cdd6f4;
      }
      #workspaces button {
        padding: 0 8px;
        color: #6c7086;
      }
      #workspaces button.active {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
      }
      #clock {
        padding: 0 12px;
        color: #cdd6f4;
      }
      #pulseaudio {
        padding: 0 10px;
        color: #f9e2af;
      }
      #pulseaudio.muted {
        color: #6c7086;
      }
      #network {
        padding: 0 10px;
        color: #a6e3a1;
      }
      #cpu {
        padding: 0 10px;
        color: #89b4fa;
      }
      #memory {
        padding: 0 10px;
        color: #cba6f7;
      }
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    # Use the system-provided package from NixOS programs.hyprland.enable
    package = null;
    portalPackage = null;
    configType = "lua";

    submaps.resize = {
      settings.bind = [
        { _args = [ "H" (mkLuaInline ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'') { repeating = true; } ]; }
        { _args = [ "L" (mkLuaInline ''hl.dsp.window.resize({ x = 20, y = 0, relative = true })'') { repeating = true; } ]; }
        { _args = [ "K" (mkLuaInline ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'') { repeating = true; } ]; }
        { _args = [ "J" (mkLuaInline ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'') { repeating = true; } ]; }
        { _args = [ "escape" (mkLuaInline ''hl.dsp.submap("reset")'') ]; }
        { _args = [ "Return" (mkLuaInline ''hl.dsp.submap("reset")'') ]; }
      ];
    };

    settings = {
      monitor = [
        # Fallback: any monitor at preferred resolution, 1x scale
        # Override in host config for machine-specific monitor layout
        { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
      ];

      config = {
        general = {
          border_size = 3;
          gaps_in = 3;
          gaps_out = 6;
          "col.active_border" = "rgba(89b4faee)";
          "col.inactive_border" = "rgba(45475aaa)";
        };

        decoration = {
          dim_inactive = true;
          dim_strength = 0.25;
          blur = {
            enabled = true;
            size = 8;
            passes = 2;
            new_optimizations = true;
            noise = 0.0117;
            contrast = 0.8917;
            brightness = 0.8172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
          };
        };

        animations.enabled = true;

        misc = {
          mouse_move_enables_dpms = true;
          disable_hyprland_logo = true;
        };

        ecosystem.no_update_news = true;

        dwindle.preserve_split = true;

        master.new_status = "master";

        input = {
          kb_layout = "us,cz";
          repeat_rate = 50;
          repeat_delay = 300;
          sensitivity = 0;
          accel_profile = "flat";
        };

        debug.disable_logs = false;
      };

      curve = [
        { _args = [ "easeOutQuint" (mkLuaInline "{ type = \"bezier\", points = {{0.23,1},{0.32,1}} }") ]; }
        { _args = [ "easeInOutCubic" (mkLuaInline "{ type = \"bezier\", points = {{0.65,0.05},{0.35,0.95}} }") ]; }
        { _args = [ "linear" (mkLuaInline "{ type = \"bezier\", points = {{0,0},{1,1}} }") ]; }
        { _args = [ "almostLinear" (mkLuaInline "{ type = \"bezier\", points = {{0.5,0.5},{0.75,1.0}} }") ]; }
        { _args = [ "quick" (mkLuaInline "{ type = \"bezier\", points = {{0.15,0},{0.1,1}} }") ]; }
      ];

      animation = [
        { leaf = "global"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "border"; enabled = true; speed = 5.39; bezier = "easeOutQuint"; }
        { leaf = "windows"; enabled = true; speed = 4.79; bezier = "easeOutQuint"; }
        { leaf = "windowsIn"; enabled = true; speed = 4.1; bezier = "easeOutQuint"; style = "popin 87%"; }
        { leaf = "windowsOut"; enabled = true; speed = 1.49; bezier = "linear"; style = "popin 87%"; }
        { leaf = "fadeIn"; enabled = true; speed = 1.73; bezier = "almostLinear"; }
        { leaf = "fadeOut"; enabled = true; speed = 1.46; bezier = "almostLinear"; }
        { leaf = "fade"; enabled = true; speed = 3.03; bezier = "quick"; }
        { leaf = "layers"; enabled = true; speed = 3.81; bezier = "easeOutQuint"; }
        { leaf = "layersIn"; enabled = true; speed = 4; bezier = "easeOutQuint"; style = "fade"; }
        { leaf = "layersOut"; enabled = true; speed = 1.5; bezier = "linear"; style = "fade"; }
        { leaf = "fadeLayersIn"; enabled = true; speed = 1.79; bezier = "almostLinear"; }
        { leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear"; }
        { leaf = "workspaces"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "slide"; }
        { leaf = "workspacesIn"; enabled = true; speed = 1.21; bezier = "almostLinear"; style = "slide"; }
        { leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "slide"; }
      ];

      env = [
        { _args = [ "NIXOS_OZONE_WL" "1" ]; }
        { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
        { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
        { _args = [ "QT_QPA_PLATFORM" "wayland" ]; }
        # GDK: prefer Wayland, fall back to X11 (Steam/CEF need the fallback)
        { _args = [ "GDK_BACKEND" "wayland,x11,*" ]; }
        { _args = [ "_JAVA_AWT_WM_NONREPARENTING" "1" ]; }
        # SDL: intentionally NOT forced to wayland — Steam's CEF GPU subprocess uses
        # GLX (X11 OpenGL) and crashes when SDL forces the Wayland path
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "XCURSOR_THEME" "Adwaita" ]; }
      ];

      on = [
        {
          _args = [
            "hyprland.start"
            (mkLuaInline ''function()
              hl.exec_cmd("waybar")
              hl.exec_cmd("swaync")
              hl.exec_cmd("wl-paste --watch cliphist store")
              hl.exec_cmd("[workspace special:terminal silent] ${terminal}")
              hl.exec_cmd("wlsunset -l 50.08 -L 14.44 -T 6500 -t 3500")
              hl.exec_cmd("${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent")
              hl.exec_cmd("firefox")
            end'')
          ];
        }
      ];

      window_rule = [
        {
          name = "satty-float-fullscreen";
          match.class = "^com\\.gabm\\.satty$";
          float = true;
          maximize = true;
        }
        {
          name = "mpv-float";
          match.class = "^mpv$";
          float = true;
          size = "960 540";
          center = true;
        }
        {
          name = "pip-float";
          match.title = "^Picture.in.Picture$";
          float = true;
          pin = true;
        }
      ];

      bind = [
        { _args = [ "SUPER + Return" (mkLuaInline ''hl.dsp.exec_cmd("${terminal}")'') ]; }
        { _args = [ "SUPER + Space" (mkLuaInline ''hl.dsp.exec_cmd("rofi -show drun")'') ]; }
        { _args = [ "SUPER + SHIFT + Q" (mkLuaInline "hl.dsp.window.kill()") ]; }
        { _args = [ "SUPER + D" (mkLuaInline ''hl.dsp.exec_cmd("thunar")'') ]; }
        { _args = [ "SUPER + H" (mkLuaInline ''hl.dsp.focus({ direction = "l" })'') ]; }
        { _args = [ "SUPER + L" (mkLuaInline ''hl.dsp.focus({ direction = "r" })'') ]; }
        { _args = [ "SUPER + K" (mkLuaInline ''hl.dsp.focus({ direction = "u" })'') ]; }
        { _args = [ "SUPER + J" (mkLuaInline ''hl.dsp.focus({ direction = "d" })'') ]; }
        { _args = [ "SUPER + F" (mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'') ]; }
        { _args = [ "SUPER + T" (mkLuaInline ''hl.dsp.workspace.toggle_special("terminal")'') ]; }
        { _args = [ "SUPER + SHIFT + H" (mkLuaInline ''hl.dsp.window.move({ direction = "l" })'') ]; }
        { _args = [ "SUPER + SHIFT + L" (mkLuaInline ''hl.dsp.window.move({ direction = "r" })'') ]; }
        { _args = [ "SUPER + SHIFT + K" (mkLuaInline ''hl.dsp.window.move({ direction = "u" })'') ]; }
        { _args = [ "SUPER + SHIFT + J" (mkLuaInline ''hl.dsp.window.move({ direction = "d" })'') ]; }
        { _args = [ "SUPER + CTRL + H" (mkLuaInline ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'') ]; }
        { _args = [ "SUPER + CTRL + L" (mkLuaInline ''hl.dsp.window.resize({ x = 20, y = 0, relative = true })'') ]; }
        { _args = [ "SUPER + CTRL + K" (mkLuaInline ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'') ]; }
        { _args = [ "SUPER + CTRL + J" (mkLuaInline ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'') ]; }
        { _args = [ "SUPER + 1" (mkLuaInline ''hl.dsp.focus({ workspace = "1" })'') ]; }
        { _args = [ "SUPER + 2" (mkLuaInline ''hl.dsp.focus({ workspace = "2" })'') ]; }
        { _args = [ "SUPER + 3" (mkLuaInline ''hl.dsp.focus({ workspace = "3" })'') ]; }
        { _args = [ "SUPER + 4" (mkLuaInline ''hl.dsp.focus({ workspace = "4" })'') ]; }
        { _args = [ "SUPER + 5" (mkLuaInline ''hl.dsp.focus({ workspace = "5" })'') ]; }
        { _args = [ "SUPER + 6" (mkLuaInline ''hl.dsp.focus({ workspace = "6" })'') ]; }
        { _args = [ "SUPER + 7" (mkLuaInline ''hl.dsp.focus({ workspace = "7" })'') ]; }
        { _args = [ "SUPER + 8" (mkLuaInline ''hl.dsp.focus({ workspace = "8" })'') ]; }
        { _args = [ "SUPER + 9" (mkLuaInline ''hl.dsp.focus({ workspace = "9" })'') ]; }
        { _args = [ "SUPER + ALT + L" (mkLuaInline ''hl.dsp.exec_cmd("bash -c 'if hyprctl getoption general:layout | grep -q dwindle; then hyprctl keyword general:layout master; else hyprctl keyword general:layout dwindle; fi'")'') ]; }
        { _args = [ "SUPER + SHIFT + 1" (mkLuaInline ''hl.dsp.window.move({ workspace = "1" })'') ]; }
        { _args = [ "SUPER + SHIFT + 2" (mkLuaInline ''hl.dsp.window.move({ workspace = "2" })'') ]; }
        { _args = [ "SUPER + SHIFT + 3" (mkLuaInline ''hl.dsp.window.move({ workspace = "3" })'') ]; }
        { _args = [ "SUPER + SHIFT + 4" (mkLuaInline ''hl.dsp.window.move({ workspace = "4" })'') ]; }
        { _args = [ "SUPER + SHIFT + 5" (mkLuaInline ''hl.dsp.window.move({ workspace = "5" })'') ]; }
        { _args = [ "SUPER + SHIFT + 6" (mkLuaInline ''hl.dsp.window.move({ workspace = "6" })'') ]; }
        { _args = [ "SUPER + SHIFT + 7" (mkLuaInline ''hl.dsp.window.move({ workspace = "7" })'') ]; }
        { _args = [ "SUPER + SHIFT + 8" (mkLuaInline ''hl.dsp.window.move({ workspace = "8" })'') ]; }
        { _args = [ "SUPER + SHIFT + 9" (mkLuaInline ''hl.dsp.window.move({ workspace = "9" })'') ]; }
        { _args = [ "SUPER + SHIFT + S" (mkLuaInline ''hl.dsp.window.move({ workspace = "special:slack" })'') ]; }
        { _args = [ "SUPER + SHIFT + B" (mkLuaInline ''hl.dsp.window.move({ workspace = "special:brave" })'') ]; }
        { _args = [ "SUPER + grave" (mkLuaInline ''hl.dsp.exec_cmd("hyprctl switchxkblayout all next")'') ]; }
        { _args = [ "SUPER + W" (mkLuaInline ''hl.dsp.exec_cmd("rofi -show window")'') ]; }
        { _args = [ "SUPER + N" (mkLuaInline ''hl.dsp.exec_cmd("swaync-client -t")'') ]; }
        { _args = [ "SUPER + V" (mkLuaInline ''hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy")'') ]; }
        { _args = [ "SUPER + escape" (mkLuaInline ''hl.dsp.exec_cmd("rofi -show p -modi p:rofi-power-menu")'') ]; }
        { _args = [ "Print" (mkLuaInline ''hl.dsp.exec_cmd("grimblast copysave screen")'') ]; }
        { _args = [ "SUPER + Print" (mkLuaInline ''hl.dsp.exec_cmd("grimblast save active - | satty --filename - --copy-command wl-copy")'') ]; }
        { _args = [ "SUPER + SHIFT + Print" (mkLuaInline ''hl.dsp.exec_cmd("grimblast save area - | satty --filename - --copy-command wl-copy")'') ]; }
        { _args = [ "SUPER + R" (mkLuaInline ''hl.dsp.exec_cmd("screenrec-gif")'') ]; }
        { _args = [ "SUPER + M" (mkLuaInline ''hl.dsp.window.fullscreen({ mode = 1 })'') ]; }
        { _args = [ "SUPER + SHIFT + M" (mkLuaInline ''hl.dsp.window.fullscreen({ mode = 0 })'') ]; }
        { _args = [ "SUPER + CTRL + M" (mkLuaInline ''hl.dsp.layout("swapwithmaster")'') ]; }
        { _args = [ "SUPER + Z" (mkLuaInline ''hl.dsp.submap("resize")'') ]; }
        # Media keys (locked = works with input inhibitor active)
        { _args = [ "XF86AudioMute" (mkLuaInline ''hl.dsp.exec_cmd("pamixer -t")'') { locked = true; } ]; }
        { _args = [ "XF86AudioPlay" (mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; } ]; }
        { _args = [ "XF86AudioPrev" (mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'') { locked = true; } ]; }
        { _args = [ "XF86AudioNext" (mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'') { locked = true; } ]; }
        # Volume keys (repeating = hold to repeat)
        { _args = [ "XF86AudioRaiseVolume" (mkLuaInline ''hl.dsp.exec_cmd("pamixer -i 5")'') { repeating = true; } ]; }
        { _args = [ "XF86AudioLowerVolume" (mkLuaInline ''hl.dsp.exec_cmd("pamixer -d 5")'') { repeating = true; } ]; }
        # Mouse binds
        { _args = [ "SUPER + mouse:272" (mkLuaInline "hl.dsp.window.drag()") { mouse = true; } ]; }
        { _args = [ "SUPER + mouse:273" (mkLuaInline "hl.dsp.window.resize()") { mouse = true; } ]; }
      ];
    };
  };
}
