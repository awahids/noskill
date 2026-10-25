#!/usr/bin/env bash
set -eu

prompt="${*:-}"
if [ -z "$prompt" ]; then
  printf '%s\n' 'noskill intent: default suggestion -> /noskill:lazy'
  exit 0
fi

lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

if printf '%s' "$lower" | grep -Eiq 'fitur|feature|modul|buat fitur|tambah fitur|new feature|new module|add feature'; then
  printf '%s\n' 'noskill intent: likely feature work -> /noskill:feature-flow'
elif printf '%s' "$lower" | grep -Eiq 'bug|error|gagal|tidak jalan|fix|debug|error handling|broken'; then
  printf '%s\n' 'noskill intent: likely bug fix -> /noskill:tiket fix'
elif printf '%s' "$lower" | grep -Eiq 'lanjut|resume|continue|tiket lama|ticket lama|terputus|resume session'; then
  printf '%s\n' 'noskill intent: likely continuation -> /noskill:tiket lanjut'
else
  printf '%s\n' 'noskill intent: default -> /noskill:lazy'
fi
