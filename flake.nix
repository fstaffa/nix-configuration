{
  description = "stskeygen for cimpress aws";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, emacs-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        stskeygen = import ./packages/stskeygen.nix {inherit nixpkgs system; };
        terminal-helpers = with import nixpkgs {system = system;};
          [
            tmux
            thefuck
            zoxide
            starship
            broot
            fzf
            tealdeer
            bat
            mcfly
          ];
        gui = with import nixpkgs {system = system;};
          if stdenv.isLinux then
            [
              flameshot
              xclip
            ]
          else [];
        emacs = with import nixpkgs {system = system; overlays = [emacs-overlay.overlay];};
          [
            aspell
            ripgrep
            fd
            curl
            emacsGit
          ];
        work =  with import nixpkgs {system = system; config.allowUnfree = true;};
        [
          stskeygen
          awscli2
          ssm-session-manager-plugin
        ];
      in
        {
          formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
          packages.stskeygen = stskeygen;

          packages.common = with import nixpkgs {system = system;}; buildEnv {
            name = "home-env";
            paths = [
              tokei
              fnm
              ripgrep
              jq
              curl
              aria
              graphviz
              shellcheck
            ] ++ terminal-helpers ++ gui ++ work ++ emacs;
          };
        }
    );
}
