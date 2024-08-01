{ config, lib, pkgs, ... }:

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
      window.startup_mode = "Maximized";
    };
  };
}
