# Shell for bootstrapping flake-enabled nix and home-manager
{ pkgs, ... }:
pkgs.mkShell {
  # Enable experimental features without having to specify the argument
  NIX_CONFIG = "experimental-features = nix-command flakes";

  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    git
    nixfmt
    nixd
    nodePackages_latest.vscode-langservers-extracted
  ];
}
