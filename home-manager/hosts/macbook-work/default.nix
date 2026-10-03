{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/gpg-personal
    ../../shared/base-terminal
    ../../shared/terminal
    ../../shared/developer-terminal
    ../../shared/ghostty
    ../../shared/work
    ../../shared/emacs
  ];

  home = {
    username = "fstaffa";
    homeDirectory = "/Users/fstaffa";
    stateVersion = "22.05";
  };

  # The system-level nix.gc only cleans root's profiles; this prunes the
  # user's home-manager / nix profile generations.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };

  home.packages = with pkgs; [
    coreutils
    fnm
  ];

  programs.gpg-personal = {
    enable = true;
    cardId = 23405290;
    # old keychain
    #cardId = 4547547;
    #cardId = 4256693;
  };

  programs.claude.extraInstructions = ''
    ## Machine

    This machine (raptor) is a Cimpress work MacBook running macOS via nix-darwin.

    - Don't suggest `brew install` for CLI tools — ad-hoc tools go through
      `nix shell nixpkgs#<pkg>` or get added to this flake. GUI apps are
      reasonably installed via `brew cask`.
    - Go binaries (e.g. `glab`) need `SSL_CERT_FILE` pointed at nix's cacert
      bundle instead of the macOS keychain for TLS to work in the sandbox.
    - Claude Code runs sandboxed here (macOS Seatbelt) — some paths or
      network destinations that exist on this machine will still be denied
      if they're outside the sandbox allowlist for the session.
  '';

  # add vscode to the path
  home.sessionPath = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "${config.home.homeDirectory}/.rd/bin"
  ];
  programs.zsh = {
    initContent = lib.mkBefore ''

      if command -v fnm &> /dev/null
      then
        eval "$(fnm env --use-on-cd)"
      fi
    '';
  };
}
