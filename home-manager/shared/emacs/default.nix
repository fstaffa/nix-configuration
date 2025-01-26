{ config, lib, pkgs, emacs30-pgtk, inputs, ... }:

let
  doomDir = "${config.home.homeDirectory}/data/generated/doom.d/";
  doomGitUrl = "https://github.com/doomemacs/doomemacs";
  doomConfiguration = "${config.home.homeDirectory}/data/personal/doom.d";
  doomConfigurationUrl = "git@github.com:fstaffa/dotdoom.git";
in {
  home.packages = with pkgs;
    [
      python3 # treemacs
      (aspellWithDicts (ds: with ds; [ en ]))
      ripgrep
      fd
      curl

      # needed for emacs-sqllite
      gcc
      # vterm
      cmake
      libtool

      # needed for vterm
      emacsPackages.vterm

      nodejs
      # Typescript
      nodePackages.typescript
      nodePackages.typescript-language-server

      nodePackages.prettier

      # needed for lsp-mode
      unzip

      terraform-ls

      # html mode formatting
      html-tidy

      exercism
    ] ++ [ emacs30-pgtk ];

  home.file = {
    ".emacs.d".source = inputs.chemacs2;
    ".config/chemacs/profiles.el".text = ''
      (("default" . ((user-emacs-directory . "${doomDir}")
             (env . (("DOOMDIR" . "${doomConfiguration}"))))))
    '';
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

  programs.zsh.initExtra = ''
    export DOOMDIR='${doomConfiguration}'
    export PATH="$PATH:${doomDir}/bin"
    export VISUAL='emacsclient -c -t'
    export EDITOR='emacsclient -c -t'
  '';
}
