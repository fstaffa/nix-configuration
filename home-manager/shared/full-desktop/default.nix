{ pkgs, ... }:

let
  godotWayland = pkgs.symlinkJoin {
    name = "godot-wayland-${pkgs.godot.version}";
    paths = [ pkgs.godot ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in godot godot4 godot4.7; do
        rm $out/bin/$bin
        makeWrapper ${pkgs.godot}/bin/$bin $out/bin/$bin --add-flags "--display-driver wayland"
      done
      for desktop in $out/share/applications/*.desktop; do
        cp --remove-destination "$(readlink -f "$desktop")" "$desktop"
        substituteInPlace "$desktop" --replace-quiet "${pkgs.godot}/bin/godot" "$out/bin/godot"
      done
    '';
    meta.mainProgram = "godot";
  };
in
{
  imports = [
    ../developer-desktop
    ../hyprland/full.nix
  ];

  services.easyeffects.enable = true;

  home.packages = with pkgs; [
    # Development
    jetbrains.datagrip
    jetbrains.webstorm
    jetbrains.rider

    # video
    obs-studio
    v4l-utils

    streamcontroller

    quickemu

    bambu-studio-appimage

    prismlauncher

    godotWayland

    inkscape
  ];
}
