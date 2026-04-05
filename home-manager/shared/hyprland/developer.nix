{ pkgs, ... }:

let
  privateBraveMover = pkgs.writeShellApplication {
    name = "hypr-private-brave-mover";
    runtimeInputs = with pkgs; [ socat hyprland jq ];
    text = ''
      handle() {
        case $1 in
          windowtitlev2*)
            rest="''${1#windowtitlev2>>}"
            addr="''${rest%%,*}"
            title="''${rest#*,}"
            if [[ "$title" == *"Private"* ]]; then
              sleep 0.2
              class=$(hyprctl clients -j | jq -r ".[] | select(.address == \"0x$addr\") | .class")
              if [[ "$class" == "brave-browser" ]]; then
                hyprctl dispatch movetoworkspacesilent "special:private,address:0x$addr"
              fi
            fi
            ;;
        esac
      }

      socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
        | while read -r line; do handle "$line"; done
    '';
  };
in
{
  home.packages = [ privateBraveMover ];

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
        "${privateBraveMover}/bin/hypr-private-brave-mover"
      ];

      bind = [
        "$mod, E, focuswindow, class:emacs"
        "$mod, S, togglespecialworkspace, slack"
        "$mod, B, togglespecialworkspace, brave"
      ];
    };
  };
}
