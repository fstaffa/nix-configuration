{ ... }:
{
  programs.hyprland.enable = true;

  # Removable media: udisks2 does the mounting (polkit-authorised for the
  # active session), gvfs lets Thunar see the mounts.
  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
