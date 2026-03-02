{ lib, pkgs, config, ... }:
{
  options.myDesktop.hyprland.enable = lib.mkEnableOption "Hyprland home-manager integration";

  config = lib.mkIf config.myDesktop.hyprland.enable {
    home.packages = with pkgs; [
      wofi
      mako
      waybar
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
      '';

      settings = {
        monitor = [
          # Dell U3224KBA — 6K panel on DP-6, 2x scale → logical 3072x1728
          "DP-6,6144x3456@60,0x0,2"
          # Fallback: any other monitor at preferred resolution, 1x scale
          ",preferred,auto,1"
        ];

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
          # SDL: intentionally NOT forced to wayland — Steam's CEF GPU subprocess uses
          # GLX (X11 OpenGL) and crashes when SDL forces the Wayland path
        ];

        exec-once = [
          "waybar"
          "mako"
        ];

        debug.disable_logs = false;

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, D, exec, $launcher"
          "$mod, Q, killactive"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
        ];
      };
    };
  };
}
