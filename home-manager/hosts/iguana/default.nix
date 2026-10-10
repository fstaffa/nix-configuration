{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../shared/base-terminal
    ../../shared/terminal
    ../../modules/gpg-personal
    ../../shared/developer-terminal
    ../../shared/work
    ../../shared/emacs
    ../../shared/alacritty
    ../../shared/ghostty
    ./hyprland.nix
    ./voxtype.nix
    ../../shared/full-desktop
    ../../shared/fpv
  ];

  home = {
    username = "mathematician314";
    homeDirectory = "/home/mathematician314";
    stateVersion = "22.05";
  };

  programs.gpg-personal = {
    enable = true;
    cardId = 4157425;
  };

  programs.claude.extraInstructions = ''
    ## Machine

    This machine (iguana) runs NixOS Linux with Hyprland (Wayland).

    - Don't suggest `apt`/system package installs — ad-hoc tools go through
      `nix shell nixpkgs#<pkg>` or get added to this flake.
    - Clipboard is `wl-copy`/`wl-paste`, not `xclip`/`pbcopy`.
    - Also used for Cimpress work (home-manager imports `shared/work`), so
      work git identity/AWS profiles may apply here too.
    - Claude Code runs sandboxed here (Linux sandbox) — some paths or network
      destinations that exist on this machine will still be denied if they're
      outside the sandbox allowlist for the session.
  '';

  programs.zsh = {
    enable = true;
    initContent = ''
      VM_FOLDER=~/data/vm
      function vm {
        cd $VM_FOLDER
        find $VM_FOLDER -name '*.conf' | fzf | xargs -I {} quickemu --vm {} --display spice
        cd -
      }
    '';
  };

}
