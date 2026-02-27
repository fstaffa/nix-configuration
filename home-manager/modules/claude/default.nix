{ lib, ... }:

let
  agentsDir = ./agents;
  agentFiles = builtins.readDir agentsDir;
  mdFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) agentFiles;
in
{
  home.file = {
    ".claude/settings.json".source = ./settings.json;
  } // lib.mapAttrs' (name: _: {
    name = ".claude/agents/${name}";
    value.source = agentsDir + "/${name}";
  }) mdFiles;
}
