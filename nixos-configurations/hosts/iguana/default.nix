{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../shared/common
    ../../shared/desktop
    ../../shared/vm-host
    ./hardware-configuration.nix
    ./zfs.nix
  ];

  networking.hostName = "iguana";

  myDesktop.full.enable = true;
  myDesktop.fpv.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Load snd-usb-audio in initrd so it's ready before USB mic is enumerated at ~3s (race condition fix)
  boot.initrd.kernelModules = [ "snd-usb-audio" ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

  # SDDM offers both "Hyprland" (hyprland.desktop, plain start-hyprland) and
  # "Hyprland (uwsm-managed)" (hyprland-uwsm.desktop). The uwsm-wrapped one is
  # broken here — `uwsm start` fails immediately with "Command ['systemctl',
  # '--user', 'start', 'wayland-session-bindpid@N.service'] returned non-zero
  # exit status 5" (unit not found), which tears the session down instantly
  # and leaves a blank VT with no error dialog — looks exactly like a freeze.
  # Force the plain, known-working session so the greeter can't pick the
  # broken one by default.
  services.displayManager.defaultSession = "hyprland";

  # The DENON AVR's fake HDMI-CEC display finishes negotiating (kernel:
  # "DM_MST: Differing MST start on aconnector") before the real monitor's
  # MST link does. Xorg reads and commits its initial output config the
  # instant it starts — well before SDDM's Xsetup/DisplayCommand ever runs
  # (confirmed: sddm logs "Running display setup script" and "Display server
  # started" 1.5ms apart, i.e. it does not wait for that script), so nothing
  # done from inside Xsetup can affect Xorg's initial probe. The only place
  # this race can actually be fixed is before Xorg starts at all: block
  # display-manager.service until the real monitor's EDID (identified by
  # NOT containing the AVR's "DENON" product-name string, queried directly
  # via drm_info against the kernel DRM ioctl — bypassing Xorg entirely) is
  # actually present on the discrete GPU (card1, confirmed live via
  # `hyprctl monitors` -> DP-6). See home-manager/hosts/iguana/hyprland.nix
  # for the analogous Hyprland-side fix for the same underlying race.
  systemd.services.display-manager.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "wait-for-real-monitor" ''
      for i in $(seq 1 100); do
        data=$(${pkgs.drm_info}/bin/drm_info -j /dev/dri/card1 2>/dev/null \
          | ${pkgs.jq}/bin/jq -r '.["/dev/dri/card1"].connectors[] | select(.status==1) | .properties.EDID.data // empty')
        while IFS= read -r b64; do
          if [ -n "$b64" ] && ! echo "$b64" | base64 -d 2>/dev/null | grep -aq DENON; then
            exit 0
          fi
        done <<< "$data"
        sleep 0.1
      done
      exit 0
    '')
  ];

  users.users.mathematician314 = {
    uid = 1000;
    isNormalUser = true;
    description = "mathematician314";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword = "$6$rounds=65536$52ozQfxuGrmWZoNo$P8rggZJwwVLeShjLdNciD.EYmsHJ3N2W82drhToZnmzdl7PXC9JzpRzEHbrr6v.6/m8VQl4erGxmSvJ6aZG0T/";
  };

  system.stateVersion = "22.05";
}
