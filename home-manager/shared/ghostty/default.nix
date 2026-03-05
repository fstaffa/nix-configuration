{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      font-family = "PragmataPro Mono Liga";
      theme = "iTerm2 Solarized Light";
      copy-on-select = true;

      # Hyprland: let the WM own decorations; new window per invocation
      window-decoration = "none";
      gtk-single-instance = false;
      resize-overlay = "never";

      # UX
      mouse-hide-while-typing = true;
      cursor-style = "block";
      cursor-style-blink = false;
    };
  };
}
