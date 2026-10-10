# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Nix configuration repository using flakes for declarative system management across multiple platforms: NixOS (Linux), nix-darwin (macOS), and home-manager (standalone). The repository supports multiple machines with host-specific and shared module configurations.

## Architecture

The flake structure follows a three-tier architecture:

1. **Platform-specific configurations**: Top-level directories for each platform
   - `nixos-configurations/` - NixOS system configurations
   - `darwin-configurations/` - macOS (nix-darwin) system configurations
   - `home-manager/` - Home Manager user environment configurations
   - `common/` - Files shared across platforms (e.g. `certificates/`)

2. **Host-specific vs shared modules**: Each platform directory contains:
   - `hosts/` - Per-machine configurations that import from shared modules
   - `shared/` - Reusable modules. NixOS: `common`, `desktop`, `proxmox-guest`, `ssh-server`, `vm`, `vm-host`. Home-manager: `base-terminal`, `developer-terminal`, `base-desktop`, `developer-desktop`, `full-desktop`, `main-desktop`, `hyprland`, `emacs`, `work`, etc.
   - `modules/` - Custom home-manager modules (home-manager only): `agent-os`, `aws`, `claude`, `gpg-personal`, `openshell`, `project`

3. **Flake outputs**: Defined in `flake.nix`:
   - `homeConfigurations` - Home Manager profiles (mathematician314@iguana, mathematician314@raptor-vm, fstaffa@raptor)
   - `nixosConfigurations` - NixOS systems (iguana, vm-test, base-server-iso, downloader, raptor-vm)
   - `darwinConfigurations` - macOS systems (raptor)
   - `legacyPackages` - Package overlays

   Note: the `raptor` outputs (darwin and `fstaffa@raptor` home-manager) are backed by the `macbook-work` host directories.

## Key Commands

### Testing changes
```sh
# Test NixOS configuration build (without applying)
make test.nixos
# or: nixos-rebuild build --flake "."

# Test home-manager configuration build (without applying)
make test.homemanager
# or: home-manager build --flake "."

# Update flake inputs and test everything
make test.update
```

### Applying configurations
```sh
# Apply both NixOS and home-manager on Linux
make switch.linux

# Apply NixOS system configuration only
sudo nixos-rebuild switch --flake "."

# Apply home-manager only
home-manager switch --flake "."

# Apply both home-manager and darwin on macOS
make switch.macos

# Apply darwin (macOS) configuration only
darwin-rebuild switch --flake ".#raptor"
```

### Updating dependencies
```sh
make update
# or: nix flake update
```

### Formatting
The flake defines a formatter (nixfmt-rfc-style) for all systems:
```sh
nix fmt
```

## Hosts

- **iguana**: Main Linux desktop (x86_64, NixOS with ZFS, Hyprland, VM host)
- **raptor**: Work MacBook (aarch64-darwin, macOS with nix-darwin); host directories are named `macbook-work`
- **raptor-vm**: Developer VM (x86_64, NixOS with disko, `myDesktop.developer`)
- **vm-test**: Test VM (x86_64, NixOS)
- **base-server-iso**: Server installation ISO
- **downloader**: Server configuration

## Special Considerations

### Emacs
Uses emacs-overlay with custom Emacs 31 builds from source. The terminal is ghostel, whose native module is a prebuilt binary downloaded on first use (no vterm compilation needed). The Doom config, where ghostel is set up, lives in a separate repository, not here.

### ZFS Installation
For systems like iguana, ZFS installation follows a custom script at `nixos-configurations/hosts/iguana/zfs-install.sh`. See README.md for full installation procedure.

### Personal Packages
The flake imports a personal package repository (`github:fstaffa/nix-packages`) passed as `extraSpecialArgs` to configurations.

### Custom CA Certificate
The darwin host and all NixOS hosts (via `nixos-configurations/shared/common`) trust the custom CAs `common/certificates/ca.pem` and `common/certificates/home-arpa-ca.crt`.

### Custom Packages
The `packages/` directory contains custom package definitions that are automatically discovered by `packages/default.nix`.

#### Adding New Packages
When adding a new package:
1. Create a new subdirectory in `packages/` (e.g., `packages/my-package/`)
2. Add a `default.nix` file in that directory with the package definition
3. **IMPORTANT**: Add the new package to git before building: `git add packages/my-package/`
4. Build and test the package: `nix build .#my-package`
5. Verify the package runs correctly: `nix run .#my-package`

The flake automatically discovers all subdirectories in `packages/` and makes them available as flake outputs. No modification to `flake.nix` is needed when adding new packages.

Platform-specific packages should use `meta.platforms` to restrict which systems they support (e.g., `platforms = [ "x86_64-linux" ];` for Linux-only packages).

#### Modifying Packages
**IMPORTANT**: After making any changes to packages (editing existing packages or adding new ones), always verify that the package builds successfully:
```sh
nix build .#<package-name>
```
This ensures the package definition is valid and all dependencies are correctly specified.

## Claude Code Configuration

Claude Code settings are managed via home-manager, not edited directly. The configuration lives at:

- `home-manager/modules/claude/settings.json` — main settings (deployed to `~/.claude/settings.json`)
- `home-manager/modules/claude/statusline.sh` — status line script (deployed to `~/.local/bin/claude-statusline`)
- `home-manager/modules/claude/agents/` — custom agent definitions
- `home-manager/modules/claude/hooks/` — PreToolUse hook scripts (block `git -C`-style global flags, block `gh api` writes)
- `home-manager/modules/claude/CLAUDE.md` — Claude Code instructions deployed by the module
- `home-manager/modules/claude/output-styles/` — output style definitions

To apply changes: `home-manager switch --flake "."` (or `make switch.linux` on iguana).

## Configuration Patterns

When modifying configurations:
- Host-specific settings go in `hosts/<hostname>/default.nix`
- Reusable functionality belongs in `shared/<module-name>/`
- Hardware-specific config in `hosts/<hostname>/hardware-configuration.nix`
- System state versions are pinned per-host (don't change unless necessary)

### Hyprland autostart apps must target an explicit workspace

Every `hl.exec_cmd(...)` call that launches a windowed app in a `settings.on` startup handler (see
`home-manager/shared/hyprland/*.nix`) must use the `[workspace <name> silent]`
rule tag, e.g. `hl.exec_cmd("[workspace 1 silent] firefox")`. A bare
`hl.exec_cmd("firefox")` launches onto whatever workspace is focused at
startup — which can be a workspace bound to a non-rendering monitor (e.g. one
mirroring another display), leaving the app running but invisible on any
screen. Never add a new autostart app without this tag. Windowless background daemons (waybar, swaync, wl-paste, wlsunset, polkit agent) are exempt.

