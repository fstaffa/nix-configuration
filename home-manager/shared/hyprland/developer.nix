{ ... }:

{
  wayland.windowManager.hyprland = {
    extraConfig = ''
      windowrule {
        name = slack-special
        match:class = ^Slack$
        workspace = special:slack silent
      }

      windowrule {
        name = brave-special
        match:class = ^brave-browser$
        workspace = special:brave silent
      }

    '';

    settings = {
      exec-once = [
        "slack"
        "emacs"
        "[workspace special:brave silent] brave"
      ];

      bind = [
        "$mod, E, focuswindow, class:emacs"
        "$mod, S, togglespecialworkspace, slack"
        "$mod, B, togglespecialworkspace, brave"
      ];
    };
  };
}
