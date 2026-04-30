{ lib, pkgs, ... }:

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
    ".claude/CLAUDE.md".source = ./CLAUDE.md;
    ".claude/settings.json".source = ./settings.json;
    ".local/bin/claude-statusline" = {
      source = ./statusline.sh;
      executable = true;
    };
    ".local/bin/claude-hook-block-gh-api-writes" = {
      source = ./hooks/block-gh-api-writes.sh;
      executable = true;
    };
  } // lib.mapAttrs' (name: _: {
    name = ".claude/agents/${name}";
    value.source = agentsDir + "/${name}";
  }) mdFiles
  // lib.mapAttrs' (name: _: {
    name = ".claude/output-styles/${name}";
    value.source = outputStylesDir + "/${name}";
  }) outputStyleMdFiles;

  home.activation.registerLabeClaudeMarketplace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    MARKETPLACE_FILE="$HOME/.claude/plugins/known_marketplaces.json"
    mkdir -p "$(dirname "$MARKETPLACE_FILE")"
    if [ ! -f "$MARKETPLACE_FILE" ]; then
      echo '{}' > "$MARKETPLACE_FILE"
    fi
    ${pkgs.jq}/bin/jq --arg path "$HOME/data/cimpress/labe-claude" '
      if has("labe-claude") then . else
        . + {
          "labe-claude": {
            "source": {
              "source": "directory",
              "path": $path
            },
            "installLocation": $path,
            "lastUpdated": "1970-01-01T00:00:00.000Z"
          }
        }
      end
    ' "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp" && mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
  '';
}
