{ pkgs, ... }:
let
  edgetx = pkgs.edgetx.overrideAttrs (oldAttrs: rec {
    version = "2.11.5";
    src = pkgs.fetchFromGitHub {
      owner = "EdgeTX";
      repo = "edgetx";
      tag = "v${version}";
      fetchSubmodules = true;
      hash = "sha256-M0NiHvYZD1Qw2VYRV+TKMI0qTfF5MBdTxsBZRMMrnnk=";
    };
  });
in
{
  home.packages = [
    edgetx
  ];
}
