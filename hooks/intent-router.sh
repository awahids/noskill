#!/usr/bin/env bash
set -eu

prompt="${*:-}"
if [ -z "$prompt" ]; then
  printf '%s\n' 'Saya mendeteksi kebutuhan umum. Saya sarankan /noskill:lazy. Mau lanjut?'
  exit 0
fi

lower="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

if printf '%s' "$lower" | grep -Eiq 'normalisasi|normalize|clean data|cleaning|struktur data|data cleanup|categorize|mapping|brainstorm|ideation|idea|concept|research|analyze data|analis data|data quality'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan brainstorming atau normalisasi data. Saya sarankan /noskill:feature-flow atau /noskill:lazy untuk solusi paling mendasar. Mau lanjut?'
elif printf '%s' "$lower" | grep -Eiq 'fitur|feature|modul|buat fitur|tambah fitur|new feature|new module|add feature|implementasi|create feature|build feature|menambahkan fitur|buat halaman|tambah halaman'; then
  printf '%s\n' 'Saya mendeteksi ada kebutuhan fitur baru. Saya sarankan /noskill:feature-flow. Mau lanjut?'
elif printf '%s' "$lower" | grep -Eiq 'bug|error|gagal|tidak jalan|not working|fix|debug|broken|exception|crash|error handling|issue|masalah|bisa tidak|fail|failed'; then
  printf '%s\n' 'Saya mendeteksi ini kemungkinan bug atau error. Saya sarankan /noskill:tiket fix. Mau lanjut?'
elif printf '%s' "$lower" | grep -Eiq 'lanjut|resume|continue|next|teruskan|tiket lama|ticket lama|terputus|resume session|sambung|lanjutan'; then
  printf '%s\n' 'Saya mendeteksi Anda ingin melanjutkan pekerjaan sebelumnya. Saya sarankan /noskill:tiket lanjut. Mau lanjut?'
elif printf '%s' "$lower" | grep -Eiq 'review|audit|cek|check|inspection|code review|quality|assess|evaluasi|uji|testing|validate'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan review atau audit. Saya sarankan /noskill:tiket atau /noskill:feature-flow sesuai level pekerjaan. Mau lanjut?'
elif printf '%s' "$lower" | grep -Eiq 'document|docs|dokumentasi|write prd|spec|requirements|spesifikasi|brd|prd|technical design|desain|requirement'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan dokumen atau PRD. Saya sarankan /noskill:prd-writer atau /noskill:feature-flow. Mau lanjut?'
elif printf '%s' "$lower" | grep -Eiq 'project profile|repo profile|scan repo|struktur project|cek project|analyze repo|project overview|understand repo|lihat repo|profil project'; then
  printf '%s\n' 'Saya mendeteksi kebutuhan profil project atau analisis repo. Saya sarankan /noskill:project-profile. Mau lanjut?'
else
  printf '%s\n' 'Saya mendeteksi tugas umum. Saya sarankan /noskill:lazy untuk solusi paling sederhana. Mau lanjut?'
fi
