{ lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "PragmataPro Mono";
        bold.family = "PragmataPro Mono";
        italic.family = "PragmataPro Mono";
        bold_italic.family = "PragmataPro Mono";
      };
      selection.save_to_clipboard = true;
      window = {
        startup_mode = "Maximized";
        decorations = "None";
      };
      bell = {
        animation = "EaseOutExpo";
        duration = 100;
      };
      mouse.hide_when_typing = true;
      cursor.style = {
        shape = "Block";
        blinking = "Never";
      };
      colors = {
        primary = {
          background = "#fdf6e3";
          foreground = "#657b83";
        };
        normal = {
          black   = "#073642";
          red     = "#dc322f";
          green   = "#859900";
          yellow  = "#b58900";
          blue    = "#268bd2";
          magenta = "#d33682";
          cyan    = "#2aa198";
          white   = "#eee8d5";
        };
        bright = {
          black   = "#002b36";
          red     = "#cb4b16";
          green   = "#586e75";
          yellow  = "#657b83";
          blue    = "#839496";
          magenta = "#6c71c4";
          cyan    = "#93a1a1";
          white   = "#fdf6e3";
        };
      };
    };
  };

  programs.zsh.initContent = lib.mkAfter ''
    if [[ "$TERM" == "alacritty" ]]; then
      precmd() { print -Pn "\e]2;%~\a" }
      preexec() { print -Pn "\e]2;$1\a" }
    fi
  '';
}
