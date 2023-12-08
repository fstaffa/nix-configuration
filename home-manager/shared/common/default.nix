{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./ssh.nix ];
  home.packages = with pkgs; [
    tokei
    chezmoi
    fnm
    ripgrep
    jq
    curl
    graphviz
    shellcheck
    pkgs-unstable.terraform
    dotnet-sdk_8
    pkgs-unstable.omnisharp-roslyn
  ];

  home.sessionVariables.DOTNET_ROOT = "${pkgs.dotnet-sdk_8}";

  home.file = {
    "${config.xdg.configHome}/chezmoi/chezmoi.toml".source = ./chezmoi.toml;
    "${config.xdg.configHome}/zsh/.zimrc".source = ./zimrc;
  };

  home.shellAliases = { gs = "git status"; };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    git = let
      githubGitConfig = {
        user = {
          name = "Filip Staffa";
          email = "294522+fstaffa@users.noreply.github.com";
          signingKey = "2F542A51673EB578";
        };
        commit = { gpgSign = true; };
      };
    in {
      enable = true;
      delta.enable = true;
      extraConfig = {
        pull.ff = "only";
        core.editor = "vim";
        init.defaultBranch = "master";
        gitlab.user = "fstaffa";
        "gitlab.gitlab.com/api" = { user = "fstaffa"; };
        user = {
          name = "Filip Staffa";
          email = "294522+fstaffa@users.noreply.github.com";
        };
      };

      includes = [
        {
          condition = "gitdir:~/data/personal/";
          contents = githubGitConfig;
        }
        {
          condition = "gitdir:~/.local/share/chezmoi/";
          contents = githubGitConfig;
        }
      ];

    };

    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      envExtra = ''
        ZDOTDIR=~/.config/zsh
              XDG_CACHE_HOME=~/.cache'';
      initExtraFirst = ''
        # ZIM setup

        ZIM_HOME=''${XDG_CACHE_HOME}/zim
        # Download zimfw plugin manager if missing.
        if [[ ! -e ''${ZIM_HOME}/zimfw.zsh ]]; then
          curl -fsSL --create-dirs -o ''${ZIM_HOME}/zimfw.zsh \
              https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        fi

        source ''${ZIM_HOME}/init.zsh

        # Install missing modules, and update ''${ZIM_HOME}/init.zsh if missing or outdated.
        if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZDOTDIR:-''${HOME}}/.zimrc ]]; then
          source ''${ZIM_HOME}/zimfw.zsh init -q
        fi

        # bat as manpage
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"

        FPATH=$ZDOTDIR/completions:$FPATH

        if command -v fnm &> /dev/null
        then
          eval "$(fnm env --use-on-cd)"
        fi

        function set_aws_keys {
          export AWS_ACCESS_KEY_ID=$1
          export AWS_SECRET_ACCESS_KEY=$2
          if [[ $# > 2 ]]
          then
            export AWS_SESSION_TOKEN=$3
          fi
              }

        # edit line in editor
        autoload -U edit-command-line
        # Emacs style
        zle -N edit-command-line
        bindkey '^xe' edit-command-line
        bindkey '^x^e' edit-command-line

        # nix
        export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.nix-profile/bin"
      '';

    };
    home-manager.enable = true;
  };
}
