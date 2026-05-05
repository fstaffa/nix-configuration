#!/usr/bin/env bash
# PreToolUse hook: block git commands with global flags before the subcommand
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

# Block: git -C, git --git-dir, git --work-tree before subcommand
# Pattern anchors on: start of string, or after shell operators (|, ;, &, ()
if echo "$cmd" | grep -qE '(^|[|;&(])\s*git\s+(-C\b|--git-dir\b|--work-tree\b)'; then
  echo "Blocked: git global flags (-C, --git-dir, --work-tree) before subcommand break permission matching. Use: (cd /target && git <subcommand> ...)" >&2
  exit 2
fi
