{ config, lib, pkgs, ... }:

let
  flatpakInstall = package: lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! $(flatpak list --app) =~ "${package}" ]]; then
      $DRY_RUN_CMD flatpak install --noninteractive ${package}
    fi
  '';
in
{
  home.activation = {
    ensureFlatpakRemove = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
    installZoom = flatpakInstall "us.zoom.Zoom";
  };
}
