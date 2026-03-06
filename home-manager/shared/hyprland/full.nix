{ config, ... }:

{
  # Steam's CEF GPU subprocess crashes with SIGSEGV on AMD under Hyprland.
  # --disable-gpu disables GPU acceleration in Steam's web renderer (UI only,
  # games are unaffected). Tracked in ValveSoftware/steam-for-linux#9780.
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
    extraConfig = ''
      windowrule {
        name = steam-workspace
        match:class = ^steam$
        workspace = 5 silent
        float = yes
      }

    '';

    settings = {
      exec-once = [
        "steam"
      ];
    };
  };
}
