#!/usr/bin/env bash
set -eu

# Claude Code sends the UserPromptSubmit payload as JSON on stdin ({"prompt": "..."}).
# A prompt passed as arguments is still accepted for manual testing.
prompt="${*:-}"
if [ -z "$prompt" ] && [ ! -t 0 ]; then
  input="$(cat)"
  if command -v jq >/dev/null 2>&1; then
    prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null || true)"
  elif command -v python3 >/dev/null 2>&1; then
    prompt="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt") or "")' 2>/dev/null || true)"
  else
    prompt="$(printf '%s' "$input" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  fi
fi

# Nothing to route, or the user already picked a slash command.
trimmed="$(printf '%s' "$prompt" | tr -d '[:space:]')"
case "$trimmed" in
  ''|/*) exit 0 ;;
esac

lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

# Match keywords only at the start of a word, so "prefix" does not count as "fix".
has() {
  printf '%s' "$lower" | grep -Eq "(^|[^[:alnum:]_])($1)"
}

if has 'bug|error|gagal|tidak jalan|not working|fix|debug|broken|exception|crash|issue|masalah|fail'; then
  printf '%s\n' 'Saya mendeteksi ini kemungkinan bug atau error. Saya sarankan /noskill:tiket fix. Mau lanjut?'
elif has 'prd|brd'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan dokumen atau PRD. Saya sarankan /noskill:prd-writer atau /noskill:feature-flow. Mau lanjut?'
elif has 'fitur|feature|modul|new module|implementasi|buat halaman|tambah halaman'; then
  printf '%s\n' 'Saya mendeteksi ada kebutuhan fitur baru. Saya sarankan /noskill:feature-flow. Mau lanjut?'
elif has 'project profile|repo profile|scan repo|struktur project|cek project|analyze repo|project overview|understand repo|lihat repo|profil project'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan profil project atau analisis repo. Saya sarankan /noskill:project-profile. Mau lanjut?'
elif has 'normalisasi|normalize|clean data|cleaning|struktur data|data cleanup|categorize|mapping|brainstorm|ideation|ideas?([^[:alnum:]_]|$)|concept|research|analyze data|analis data|data quality'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan brainstorming atau normalisasi data. Saya sarankan /noskill:feature-flow atau /noskill:lazy untuk solusi paling mendasar. Mau lanjut?'
elif has 'lanjut|resume|continue|teruskan|tiket lama|ticket lama|terputus|sambung'; then
  printf '%s\n' 'Saya mendeteksi Anda ingin melanjutkan pekerjaan sebelumnya. Saya sarankan /noskill:tiket lanjut. Mau lanjut?'
elif has 'review|audit|cek|check|inspection|quality|assess|evaluasi|uji|testing|validate'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan review atau audit. Saya sarankan /noskill:tiket atau /noskill:feature-flow sesuai level pekerjaan. Mau lanjut?'
elif has 'document|docs|dokumentasi|spec([^[:alnum:]_]|$)|specification|requirement|spesifikasi|technical design|desain'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan dokumen atau PRD. Saya sarankan /noskill:prd-writer atau /noskill:feature-flow. Mau lanjut?'
else
  printf '%s\n' 'Saya mendeteksi tugas umum. Saya sarankan /noskill:lazy untuk solusi paling sederhana. Mau lanjut?'
fi
