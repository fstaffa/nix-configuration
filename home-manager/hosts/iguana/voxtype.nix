{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  mkLuaInline = lib.generators.mkLuaInline;
in
{
  imports = [ inputs.voxtype.homeManagerModules.default ];

  programs.voxtype = {
    enable = true;
    # Vulkan build runs whisper.cpp on the RX 9070 XT.
    # sqlite: upstream flake doesn't list it, so linking -lsqlite3 fails; drop once fixed upstream.
    package = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.vulkan.overrideAttrs (old: {
      paths = [
        (inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.voxtype-vulkan-unwrapped.overrideAttrs (u: {
          buildInputs = u.buildInputs ++ [ pkgs.sqlite ];
        }))
      ];
    });
    model.name = "large-v3-turbo"; # multilingual (Czech + English)
    service.enable = true;
    settings = {
      # Push-to-talk is a Hyprland bind (below), so no evdev / `input` group.
      hotkey.enabled = false;
      whisper.language = [
        "en"
        "cs"
      ];
      output = {
        mode = "type";
        fallback_to_clipboard = true;
      };
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    {
      _args = [
        "F9"
        (mkLuaInline ''hl.dsp.exec_cmd("voxtype record start")'')
      ];
    }
    {
      _args = [
        "F9"
        (mkLuaInline ''hl.dsp.exec_cmd("voxtype record stop")'')
        { release = true; }
      ];
    }
  ];
}
