{
  config,
  lib,
  pkgs,
  ...
}:

let
  name = "Filip Staffa";
  email = "294522+fstaffa@users.noreply.github.com";
  signingKey = "2F542A51673EB578";
  githubGitConfig = {
    user = {
      inherit name;
      inherit email;
      inherit signingKey;
    };
    commit = {
      gpgSign = true;
    };
  };
in

{
  imports = [
    ./ssh.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    jq
    curl
    lsof
    socat
    chezmoi
  ];

  home.sessionVariables = {
    LC_CTYPE = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    COLORFGBG = "0;15";
  };

  home.file = {
    "${config.xdg.configHome}/chezmoi/chezmoi.toml".source = ./chezmoi.toml;
    "${config.xdg.configHome}/zsh/.zimrc".source = ./zimrc;
  };

  home.shellAliases = {
    gs = "git status";
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      settings = {
        pull.ff = "only";
        fetch.prune = "true";
        core.editor = "vim";
        init.defaultBranch = "master";
        gitlab.user = "fstaffa";
        github.user = "fstaffa";
        "gitlab.gitlab.com/api" = {
          user = "fstaffa";
        };
        user = {
          inherit name;
          inherit email;
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

    jujutsu = {
      enable = true;
      ediff = true;
      settings = {
        user = {
          inherit name;
          inherit email;
        };
        ui.paginate = "never";
        signing = {
          key = signingKey;
          backend = "gpg";
          behavior = "own";
        };
        git = {
          sign-on-push = true;
        };
        "--scope" = [
          {
            "--when".repositories = [ "~/data/cimpress" ];
            user = {
              email = "fstaffa@cimpress.com";
            };
          }
        ];
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = false;
      envExtra = ''
        ZDOTDIR=~/.config/zsh
              XDG_CACHE_HOME=~/.cache'';
      initContent = lib.mkBefore ''
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
