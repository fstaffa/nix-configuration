{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.myDesktop.hyprland.enable = lib.mkEnableOption "Hyprland home-manager integration";

  config = lib.mkIf config.myDesktop.hyprland.enable {
    home.packages = with pkgs; [
      wofi
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
          lock_cmd = "pidof hyprlock || hyprlock"; # handles loginctl lock-session
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend
          after_sleep_cmd = "hyprctl dispatch dpms on"; # wake display after resume
          # Intentionally no idle timeout for locking — screen locks only on explicit command
          # ($mod+Escape → L) or before sleep.
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

    # Steam's CEF GPU subprocess crashes with SIGSEGV on AMD under Hyprland.
    # --disable-gpu disables GPU acceleration in Steam's web renderer (UI only,
    # games are unaffected). This is a known issue tracked in ValveSoftware/steam-for-linux#9780.
    # Written to ~/.local/share/applications/ (xdg.dataHome) so it takes precedence
    # regardless of XDG_DATA_DIRS order in the graphical session.
    home.file."${config.xdg.dataHome}/applications/steam.desktop".text = ''
      [Desktop Entry]
      Categories=Network;FileTransfer;Game
      Exec=steam --disable-gpu %U
      Icon=steam
      MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink
      Name=Steam
      Terminal=false
      Type=Application
      Version=1.5
    '';

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ ];
          modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" "custom/notification" "clock" ];

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
      extraConfig = ''
        windowrule {
          name = steam-workspace
          match:class = ^steam$
          workspace = 5 silent
          float = yes
        }

        windowrule {
          name = slack-special
          match:class = ^Slack$
          workspace = special:slack silent
        }

        windowrule {
          name = satty-float-fullscreen
          match:class = ^com\.gabm\.satty$
          float = yes
          maximize = yes
        }

        windowrule {
          name = mpv-float
          match:class = ^mpv$
          float = yes
          size = 960 540
          center = yes
        }

        windowrule {
          name = pip-float
          match:title = ^Picture.in.Picture$
          float = yes
          pin = yes
        }

        # System submap — enter with $mod+ESC
        bind = $mod, escape, submap, system
        submap = system
        bind = , L, exec, loginctl lock-session
        bind = , R, exec, hyprshutdown --post-cmd "systemctl reboot"
        bind = , P, exec, hyprshutdown --post-cmd "systemctl poweroff"
        bind = , S, exec, systemctl suspend
        bind = , Q, exec, hyprshutdown
        bind = , escape, submap, reset
        submap = reset
      '';

      settings = {
        monitor = [
          # Dell U3224KBA — 6K panel on DP-6, 2x scale → logical 3072x1728
          "DP-6,6144x3456@60,0x0,2"
          # Fallback: any other monitor at preferred resolution, 1x scale
          ",preferred,auto,1"
        ];

        general = {
          border_size = 3;
          gaps_in = 3;
          gaps_out = 6;
          "col.active_border" = "rgba(89b4faee)"; # blue accent
          "col.inactive_border" = "rgba(45475aaa)"; # muted grey
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

        animations = {
          enabled = true;
          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.35,0.95"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, slide"
            "workspacesIn, 1, 1.21, almostLinear, slide"
            "workspacesOut, 1, 1.94, almostLinear, slide"
          ];
        };

        misc = {
          vfr = true;
          mouse_move_enables_dpms = true;
          disable_hyprland_logo = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        input = {
          kb_layout = "us,cz";
          repeat_rate = 50;
          repeat_delay = 300;
          sensitivity = 0;
          accel_profile = "flat";
        };

        "$mod" = "SUPER";
        "$terminal" = "ghostty";
        "$launcher" = "wofi --show drun";

        env = [
          # Enable Wayland backend for NixOS-packaged Chromium/Electron apps
          "NIXOS_OZONE_WL,1"
          # Standard Wayland session variables
          "XDG_SESSION_TYPE,wayland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland"
          # GDK: prefer Wayland, fall back to X11 (Steam/CEF need the fallback)
          "GDK_BACKEND,wayland,x11,*"
          # Prevent Java/Swing (DataGrip, etc.) from double-scaling on HiDPI.
          # Without this, Java reads the 2x XWayland DPI and scales itself up on top
          # of the compositor scale, resulting in 4x total size.
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "_JAVA_OPTIONS,-Dsun.java2d.uiScale=1.0"
          # SDL: intentionally NOT forced to wayland — Steam's CEF GPU subprocess uses
          # GLX (X11 OpenGL) and crashes when SDL forces the Wayland path
          "XCURSOR_SIZE,24"
          "XCURSOR_THEME,Adwaita"
        ];

        exec-once = [
          "waybar"
          "swaync"
          "slack"
          "steam"
          "emacs"
          "wl-paste --watch cliphist store"
          "wl-paste --primary --watch wl-copy"
          "[workspace special:terminal silent] ghostty"
          "wlsunset -l 50.08 -L 14.44 -T 6500 -t 3500"
          "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
        ];

        debug.disable_logs = false;

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, E, focuswindow, class:emacs"
          "$mod, Space, exec, $launcher"
          "$mod, Q, killactive"
          "$mod, D, exec, dolphin"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, F, togglefloating"
          "$mod, T, togglespecialworkspace, terminal"
          "$mod, S, togglespecialworkspace, slack"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"
          "$mod CTRL, H, resizeactive, -20 0"
          "$mod CTRL, L, resizeactive, 20 0"
          "$mod CTRL, K, resizeactive, 0 -20"
          "$mod CTRL, J, resizeactive, 0 20"
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          # Toggle between dwindle and master layout
          "$mod ALT, L, exec, bash -c 'if hyprctl getoption general:layout | grep -q dwindle; then hyprctl keyword general:layout master; else hyprctl keyword general:layout dwindle; fi'"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          # Keyboard layout toggle (us ↔ cz)
          "$mod, grave, exec, hyprctl switchxkblayout all next"
          # Notification center
          "$mod, N, exec, swaync-client -t"
          # Clipboard history
          "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
          # Screenshots
          ", Print, exec, grimblast copysave screen"
          "$mod, Print, exec, grimblast save active - | satty --filename - --copy-command wl-copy"
          "$mod SHIFT, Print, exec, grimblast save area - | satty --filename - --copy-command wl-copy"
        ];

        bindl = [
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
        ];

        binde = [
          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
