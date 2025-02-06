{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      font-family = "PragmataPro Mono Liga";
      theme = "iTerm2 Solarized Light";
    };
  };
}
