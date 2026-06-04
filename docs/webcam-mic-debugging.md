# Webcam & Microphone Debugging

## Hardware

- **Webcam**: Dell U3224KB/A 4K Webcam (`413c:c03d`) — built into the Dell U3224KBA monitor
  - Connected via USB 3.0 (5 Gbps) through 3 levels of USB hubs in the monitor
  - Exposes 4 V4L2 devices: `/dev/video0` (main: NV12/YUYV/MJPEG), `/dev/video1` (metadata), `/dev/video2` (NV12-only secondary), `/dev/video3` (metadata)
- **Microphone**: Blue Microphones (`046d:0ab7`) — directly on `usb5` (USB 2.0, `0000:12:00.4`)

## Symptoms

- Webcam: black screen / flashing in Brave; "not connected/working" on Brave startup
- Webcam works fine in OBS (direct V4L2 access)
- Microphone: unreliable

## Attempts

### 1. Load `uvcvideo` in initrd (iguana/default.nix)
**Hypothesis**: USB enumeration race condition (same as existing `snd-usb-audio` fix for mic).
**Result**: No improvement.

### 2. Disable USB autosuspend globally (iguana/default.nix)
**Change**: `boot.kernelParams = [ "usbcore.autosuspend=-1" ]`
**Hypothesis**: USB power management suspending webcam/mic mid-use.
**Result**: No improvement. Confirmed active via `/sys/module/usbcore/parameters/autosuspend = -1`.

### 3. Disable libcamera monitor in WirePlumber (iguana/default.nix)
**Change**:
```nix
services.pipewire.wireplumber.extraConfig."disable-libcamera" = {
  "wireplumber.profiles".main."monitor.libcamera" = "disabled";
};
```
**Hypothesis**: WirePlumber was exposing both a libcamera device AND V4L2 devices for the same physical webcam, causing conflicts when Brave opened the camera via XDG portal.
**Result**: libcamera device removed from PipeWire (`pw-cli` confirmed). But issue persisted.

### 4. Add `--enable-features=PipeWireCamera` to Brave (base-desktop/default.nix)
**Change**: Added `--enable-features=PipeWireCamera` to `programs.chromium.commandLineArgs`.
**Hypothesis**: Brave was accessing cameras directly via V4L2 and hitting a race condition or picking the wrong device on startup. `PipeWireCamera` routes camera through PipeWire instead.
**Result**: Flag confirmed active in Brave process. Issue persisted.

### 5. Hide secondary V4L2 streams from WirePlumber (iguana/default.nix)
**Change**:
```nix
services.pipewire.wireplumber.extraConfig."hide-webcam-secondary-streams" = {
  "monitor.v4l2.rules" = [
    {
      matches = [
        { "api.v4l2.path" = "/dev/video1"; }
        { "api.v4l2.path" = "/dev/video2"; }
        { "api.v4l2.path" = "/dev/video3"; }
      ];
      actions."update-props"."device.disabled" = true;
    }
  ];
};
```
**Hypothesis**: WirePlumber was exposing `video2` (NV12-only secondary UVC interface) as a valid camera node. Brave might be selecting it and getting a black stream.
**First attempt used `object.path = "v4l2:/dev/video1"` — wrong property name, didn't work.**
**Second attempt used `api.v4l2.path = "/dev/video1"` — confirmed working**: `pw-cli` now only shows `video0` and `video4` (OBS cam).
**Result**: pw-cli shows correct state but camera still doesn't work in Brave.

## Current State (as of debugging session)

- `/dev/video0` — owned by WirePlumber/PipeWire (V4L2 direct access returns "device busy")
- Only `v4l2:/dev/video0` and `v4l2:/dev/video4` (OBS Cam) exposed in PipeWire
- XDG Camera Portal: `IsCameraPresent = true`
- Brave: connected to PipeWire (seen as client), `PipeWireCamera` flag active
- Camera still doesn't work in Brave; works fine in OBS

## Outstanding Questions

- Is PipeWire actually holding video0 open, or only on demand?
- Is Brave's `PipeWireCamera` feature creating a PipeWire link to the camera node when camera is requested?
- Is a portal permission dialog appearing (and possibly behind other windows)?
- Does clearing the camera site permission in Brave and re-granting it help?
- Does `pw-link` show any active video links when camera is in use in Brave?
