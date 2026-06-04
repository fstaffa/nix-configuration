{ pkgs, lib, ... }:

let
  mkLuaInline = lib.generators.mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings = {
    on = [
      {
        _args = [
          "hyprland.start"
          (mkLuaInline ''function()
            hl.exec_cmd("[workspace special:slack silent] slack")
            hl.exec_cmd("emacs")
            hl.exec_cmd("[workspace special:brave silent] brave")
          end'')
        ];
      }
    ];

    window_rule = [
      {
        name = "slack-special";
        match.class = "^slack$";
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
