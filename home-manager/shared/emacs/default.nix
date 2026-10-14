{
  config,
  lib,
  pkgs,
  emacs31-pgtk,
  inputs,
  ...
}:

let
  doomDir = "${config.home.homeDirectory}/.emacs.d";
  doomGitUrl = "https://github.com/doomemacs/doomemacs";
  doomConfiguration = "${config.home.homeDirectory}/.doom.d";
  doomConfigurationUrl = "git@github.com:fstaffa/dotdoom.git";
in
{
  home.packages =
    with pkgs;
    [
      python3 # treemacs
      (aspellWithDicts (ds: with ds; [ en ]))
      ripgrep
      fd
      curl
      mediainfo
      file

      # needed for emacs-sqllite
      gcc
      gnumake

      nodejs_24
      # Typescript
      typescript
      # nixpkgs pnpmDeps hash is stale; drop once fixed upstream
      (typescript-language-server.overrideAttrs (old: {
        pnpmDeps = old.pnpmDeps.overrideAttrs {
          outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
        };
      }))

      prettier

      # needed for lsp-mode
      unzip

      terraform-ls

      # html mode formatting
      html-tidy

      exercism

      # ACP server used by agent-shell
      claude-agent-acp
    ]
    ++ (if pkgs.stdenv.hostPlatform.isDarwin then [ ] else [ emacs31-pgtk ]);

  home.file = {
    ".authinfo.gpg".source = ./.authinfo.gpg;
  };

  home.activation.cloneDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${doomDir}" ]; then
      $DRY_RUN_CMD git clone --depth=1 --single-branch ${doomGitUrl} "${doomDir}"
    fi
    if [ ! -d "${doomConfiguration}" ]; then
      $DRY_RUN_CMD git clone ${doomConfigurationUrl} "${doomConfiguration}"
    fi
  '';

  programs.zsh.initContent = ''
    export PATH="$PATH:${doomDir}/bin"
    export VISUAL='emacsclient -c -t'
    export EDITOR='emacsclient -c -t'
  '';
}
