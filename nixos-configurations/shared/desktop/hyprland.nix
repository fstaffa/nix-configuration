{ ... }:
{
  programs.hyprland.enable = true;

  # Secret Service provider (stskeygen --credential-process caches creds via
  # the keyring; without one it falls back to a file keyring and fails).
  # PAM hooks unlock the login keyring at SDDM login.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Removable media: udisks2 does the mounting (polkit-authorised for the
  # active session), gvfs lets Thunar see the mounts.
  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
