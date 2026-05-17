{ pkgs, lib, ... }:

let
  mkLuaInline = lib.generators.mkLuaInline;

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

  wayland.windowManager.hyprland.settings = {
    on = [
      {
        _args = [
          "hyprland.start"
          (mkLuaInline ''function()
            hl.exec_cmd("slack")
            hl.exec_cmd("emacs")
            hl.exec_cmd("[workspace special:brave silent] brave")
            hl.exec_cmd("${privateBraveMover}/bin/hypr-private-brave-mover")
          end'')
        ];
      }
    ];

    window_rule = [
      {
        name = "slack-special";
        match.class = "^Slack$";
        workspace = "special:slack silent";
      }
      {
        name = "brave-special";
        match.class = "^brave-browser$";
        workspace = "special:brave silent";
      }
    ];

    bind = [
      { _args = [ "SUPER + E" (mkLuaInline ''hl.dsp.focus({ window = "class:emacs" })'') ]; }
      { _args = [ "SUPER + S" (mkLuaInline ''hl.dsp.workspace.toggle_special("slack")'') ]; }
      { _args = [ "SUPER + B" (mkLuaInline ''hl.dsp.workspace.toggle_special("brave")'') ]; }
    ];
  };
}
