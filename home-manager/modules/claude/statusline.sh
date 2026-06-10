#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
pct=$(echo "$input" | jq -r '((.context_window.total_input_tokens // 0) / 200000 * 100) | floor')
branch=$(git branch --show-current 2>/dev/null)

if [[ -n "$branch" ]]; then
  echo "$branch | $model | ${pct}% ctx"
else
  echo "$model | ${pct}% ctx"
fi
