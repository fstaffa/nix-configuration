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
      mako
      grimblast
      satty
    ];

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
          modules-right = [ "clock" ];

          "hyprland/workspaces" = {
            format = "{id}";
            on-click = "activate";
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
          workspace = 9 silent
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

        # System submap — enter with $mod+ESC
        bind = $mod, escape, submap, system
        submap = system
        bind = , L, exec, loginctl lock-session
        bind = , R, exec, systemctl reboot
        bind = , S, exec, systemctl suspend
        bind = , Q, exit
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
          "col.active_border" = "rgba(89b4faee)"; # blue accent
          "col.inactive_border" = "rgba(45475aaa)"; # muted grey
        };

        decoration = {
          dim_inactive = true;
          dim_strength = 0.25;
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
        ];

        exec-once = [
          "waybar"
          "mako"
          "slack"
        ];

        debug.disable_logs = false;

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, Space, exec, $launcher"
          "$mod, Q, killactive"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, T, togglefloating"
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
          # Screenshots
          ", Print, exec, grimblast copysave screen"
          "$mod, Print, exec, grimblast save active - | satty --filename -"
          "$mod SHIFT, Print, exec, grimblast save area - | satty --filename -"
        ];
      };
    };
  };
}
