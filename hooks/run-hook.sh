#!/usr/bin/env bash
set -eu

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
RULES="$ROOT/hooks/core-rules.md"
EXTRA="$ROOT/hooks/startup-extra.md"

printf '\n'
printf '%s\n' '===================================================='
printf '%s\n' '[ noskill session-start ]'
printf '%s\n' '===================================================='

if [ -f "$RULES" ]; then
  printf '%s\n' '[core rules]'
  cat "$RULES"
  printf '\n'
fi

if [ -f "$EXTRA" ]; then
  printf '%s\n' '[startup extra]'
  cat "$EXTRA"
  printf '\n'
fi

printf '%s\n' '[startup complete]'
printf '%s\n' '===================================================='
