# 📋 IMPLEMENTATION PLAN FOR TIDAL-DL-NG ON DOWNLOADER

## **Project Analysis**

**What is tidal-dl-ng:**
- Python 3.12 application for downloading music/videos from TIDAL
- Multi-threaded downloads with quality control (up to 24-bit/192kHz)
- CLI + optional GUI (PySide6)
- Configuration-based with persistent credentials
- Requires paid TIDAL subscription

**Key Technical Details:**
- Version: 0.27.0
- Python: Strictly 3.12 (>=3.12,<3.13)
- Build system: Poetry
- Entry points: `tidal-dl-ng`, `tdn` (CLI), `tidal-dl-ng-gui`, `tdng` (GUI)
- All 14 core dependencies ✅ **available in nixpkgs**

---

## **Recommended Approach: buildPythonApplication**

**Why this approach:**
1. ✅ All dependencies available in nixpkgs python312Packages
2. ✅ Standard nixpkgs pattern - transparent and maintainable
3. ✅ No need for poetry2nix complexity
4. ✅ Follows your repo's existing patterns

**Alternative considered:**
- poetry2nix: Overkill when all deps are available; adds complexity

---

## **Implementation Steps**

### **1. Create Package Definition**

**Location:** `packages/tidal-dl-ng/default.nix`

**Structure:**
```nix
{
  lib,
  python312Packages,
  fetchFromGitHub,
  ffmpeg-full,  # For FLAC extraction
}:

python312Packages.buildPythonApplication rec {
  pname = "tidal-dl-ng";
  version = "0.27.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "exislow";
    repo = "tidal-dl-ng";
    rev = "v${version}";
    hash = "sha256-...";  # Need to calculate
  };

  nativeBuildInputs = with python312Packages; [
    poetry-core
  ];

  propagatedBuildInputs = with python312Packages; [
    requests
    mutagen
    dataclasses-json
    pathvalidate
    m3u8
    coloredlogs
    rich
    toml
    typer
    tidalapi
    python-ffmpeg
    pycryptodome
  ];

  # GUI optional dependencies
  passthru.optional-dependencies = {
    gui = with python312Packages; [
      pyside6
      pyqtdarktheme  # Using upstream, not fork
    ];
  };

  # Runtime dependency
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg-full ]}"
  ];

  # Tests require TIDAL credentials
  doCheck = false;

  meta = with lib; {
    description = "TIDAL media downloader with multithreaded capabilities";
    homepage = "https://github.com/exislow/tidal-dl-ng";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "tidal-dl-ng";
  };
}
```

**Key decisions:**
- **GUI**: Optional via `passthru.optional-dependencies` - user can opt-in
- **pyqtdarktheme-fork**: Use upstream `pyqtdarktheme` (minor theme differences acceptable)
- **FFmpeg**: Runtime dependency for FLAC extraction
- **Tests disabled**: Require TIDAL credentials (not feasible in build sandbox)

---

### **2. Add to Downloader Configuration**

**Location:** `nixos-configurations/hosts/downloader/default.nix`

**Option A: CLI Only (Recommended for server)**
```nix
{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../shared/ssh-server
  ];

  # ... existing config ...

  environment.systemPackages = [
    pkgs.tidal-dl-ng
  ];

  # Optional: systemd timer for automated favorite downloads
  systemd.services.tidal-dl-favorites = {
    description = "Download TIDAL favorites";
    serviceConfig = {
      Type = "oneshot";
      User = "username";  # Replace with actual user
      ExecStart = "${pkgs.tidal-dl-ng}/bin/tdn dl_fav tracks";
    };
  };

  systemd.timers.tidal-dl-favorites = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
```

**Option B: Include GUI**
```nix
environment.systemPackages = [
  (pkgs.tidal-dl-ng.override {
    propagatedBuildInputs = pkgs.tidal-dl-ng.propagatedBuildInputs
      ++ pkgs.tidal-dl-ng.optional-dependencies.gui;
  })
];
```

---

### **3. Configuration Management**

**Considerations:**
- Config location: `~/.config/tidal-dl-ng/` (default)
- Contains TIDAL credentials (sensitive!)
- Needs to persist across rebuilds

**Approaches:**

**A. Manual (Recommended for initial setup):**
```bash
# After deployment, SSH to downloader:
tidal-dl-ng login
tidal-dl-ng cfg  # Review settings
```

**B. Declarative (Advanced - for later):**
- Use `sops-nix` or `agenix` for secrets
- Deploy config.toml via NixOS module
- Requires credentials management setup

---

## **Potential Issues & Solutions**

| Issue | Solution |
|-------|----------|
| Python 3.12 not default | ✅ Explicitly use `python312Packages` |
| pyqtdarktheme-fork unavailable | ✅ Use upstream `pyqtdarktheme` (cosmetic diff) |
| FFmpeg not in PATH | ✅ `makeWrapperArgs` to add ffmpeg-full |
| Config persistence | Document manual login step |
| Hash calculation needed | Use `nix-prefetch-github` |

---

## **Testing Strategy**

1. **Build package:**
   ```bash
   git add packages/tidal-dl-ng/  # CRITICAL: git add before building
   nix build .#tidal-dl-ng
   ```

2. **Test CLI:**
   ```bash
   ./result/bin/tidal-dl-ng --version
   ./result/bin/tdn --help
   ```

3. **Test on downloader (dry-run):**
   ```bash
   nixos-rebuild build --flake .#downloader
   ```

4. **Deploy:**
   ```bash
   nixos-rebuild switch --flake .#downloader --target-host downloader
   ```

5. **Post-deployment:**
   ```bash
   ssh downloader
   tidal-dl-ng login
   tdn dl <test-url>
   ```

---

## **Future Enhancements**

**Phase 2 (Optional):**
1. **Service module:** Create `nixos-configurations/shared/tidal-dl-ng/` with:
   - Systemd service template
   - Timer configuration
   - Config file generation
   - Multi-user support

2. **Download management:**
   - Dedicated download directory
   - Symlink management for playlists
   - Periodic cleanup

3. **Monitoring:**
   - Download logs
   - Failure notifications
   - Storage quota management

---

## **Estimated Effort**

- Package creation: 15-20 minutes
- Testing: 10 minutes
- Deployment: 5 minutes
- Configuration: 5-10 minutes
- **Total: ~40-45 minutes**

---

## **Summary**

This is a **straightforward implementation** because:
1. All dependencies already in nixpkgs ✅
2. Clean Python project with standard build system ✅
3. Your repo already has Python packaging examples ✅
4. No complex service requirements ✅

**Recommended: Start with CLI-only on downloader, add GUI later if X11 forwarding needed.**

Ready to proceed with implementation? I can:
- Create the package definition
- Update downloader configuration
- Test the build
- Provide deployment commands
