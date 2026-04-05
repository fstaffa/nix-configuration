#!/usr/bin/env bash
# PreToolUse hook: block gh api write operations (POST/PATCH/PUT/DELETE)
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE '(^|[|;&])\s*gh api' && \
   echo "$cmd" | grep -qiE '(-X|--method)[[:space:]]+(POST|PATCH|PUT|DELETE)'; then
  echo "Blocked: gh api write operation (use explicit approval)" >&2
  exit 2
fi
