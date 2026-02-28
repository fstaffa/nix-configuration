{ lib, ... }:

let
  agentsDir = ./agents;
  agentFiles = builtins.readDir agentsDir;
  mdFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) agentFiles;

  outputStylesDir = ./output-styles;
  outputStyleFiles = builtins.readDir outputStylesDir;
  outputStyleMdFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) outputStyleFiles;
in
{
  home.file = {
    ".claude/settings.json".source = ./settings.json;
  } // lib.mapAttrs' (name: _: {
    name = ".claude/agents/${name}";
    value.source = agentsDir + "/${name}";
  }) mdFiles
  // lib.mapAttrs' (name: _: {
    name = ".claude/output-styles/${name}";
    value.source = outputStylesDir + "/${name}";
  }) outputStyleMdFiles;
}
