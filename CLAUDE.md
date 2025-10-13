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

2. **Host-specific vs shared modules**: Each platform directory contains:
   - `hosts/` - Per-machine configurations that import from shared modules
   - `shared/` - Reusable modules (e.g., common, desktop, terminal, work)
   - `modules/` - Custom NixOS/home-manager modules (home-manager only)

3. **Flake outputs**: Defined in `flake.nix`:
   - `homeConfigurations` - Home Manager profiles (mathematician314@iguana, fstaffa@raptor)
   - `nixosConfigurations` - NixOS systems (iguana, vm-test, base-server-iso, downloader)
   - `darwinConfigurations` - macOS systems (raptor)
   - `legacyPackages` - Package overlays (e.g., burpsuite pro edition)

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

# Apply darwin (macOS) configuration
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

- **iguana**: Main Linux desktop (x86_64, NixOS with ZFS, Plasma 6, VM host)
- **raptor**: Work MacBook (aarch64-darwin, macOS with nix-darwin)
- **vm-test**: Test VM (x86_64, NixOS)
- **base-server-iso**: Server installation ISO
- **downloader**: Server configuration
- **iguana-manjaro**: Home Manager on non-NixOS Manjaro system

## Special Considerations

### Emacs
Uses emacs-overlay with custom Emacs 31 builds from source. On macOS, vterm requires special compilation:
```sh
export CC=clang CXX=clang++
doom sync && doom build
```

### ZFS Installation
For systems like iguana, ZFS installation follows a custom script at `nixos-configurations/hosts/iguana/zfs-install.sh`. See README.md for full installation procedure.

### Personal Packages
The flake imports a personal package repository (`github:fstaffa/nix-packages`) passed as `extraSpecialArgs` to configurations.

### Custom CA Certificate
Darwin and potentially other configurations trust a custom CA at `common/certificates/ca.pem`.

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

## Configuration Patterns

When modifying configurations:
- Host-specific settings go in `hosts/<hostname>/default.nix`
- Reusable functionality belongs in `shared/<module-name>/`
- Hardware-specific config in `hosts/<hostname>/hardware-configuration.nix`
- System state versions are pinned per-host (don't change unless necessary)

