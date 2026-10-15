---
name: standup-update
description: >-
  Merangkum commit, task, atau catatan kerja jadi update standup (Yesterday/Today/Blockers) atau status report mingguan. Gunakan saat user minta standup, update harian, status report, atau progress report.
---

# Standup & Status Update Generator

Gunakan skill ini untuk mengubah catatan kerja mentah (commit message, daftar task, progress notes) menjadi update yang rapi dan mudah dibaca tim, tanpa perlu user menulis ulang dari nol.

## Format Standard: Daily Standup

```
**Yesterday**
- [Task/fitur yang diselesaikan, dalam bahasa hasil bukan proses — "Selesai integrasi payment gateway" bukan "Ngerjain payment gateway"]

**Today**
- [Rencana kerja hari ini, spesifik bukan generik — "Lanjut testing webhook Midtrans" bukan "Lanjut kerja"]

**Blockers**
- [Kalau ada, sebutkan spesifik apa yang menghambat dan siapa/apa yang dibutuhkan untuk resolve. Kalau tidak ada, tulis "Tidak ada" — jangan dikosongkan]
```

## Format Alternatif: Weekly/Project Status (Notion-friendly)

Untuk update mingguan atau laporan project (relevan dengan workspace Notion "melankoding"):

```
## [Nama Project] — Update Minggu [tanggal]

**Progress**
- [Poin-poin yang sudah selesai, dikelompokkan per area kalau perlu — Backend, Frontend, Integrasi]

**In Progress**
- [Yang sedang dikerjakan + estimasi selesai kalau ada]

**Next**
- [Rencana minggu depan]

**Risks/Blockers**
- [Kalau ada risiko timeline atau dependency yang belum jelas]
```

## Cara Kerja

0. **Kalau project memakai alur tiket noskill** (`docs/tickets/` ada), jadikan itu sumber utama, tanpa minta user menulis ulang:
   - Tiket yang pindah ke DONE sejak update terakhir (baris `## Riwayat` bertanggal kemarin/hari ini) → **Yesterday**
   - Tiket berstatus IN_PROGRESS, REVIEW, QA, atau BUG → **Today**
   - Tiket HOLD beserta pertanyaannya → **Blockers**
   - Lengkapi dengan `git log --since=<tanggal> --oneline` kalau perlu, tapi tulis dalam bahasa hasil, bukan daftar commit.

1. Kalau user kasih raw input (commit log, list task, atau cerita bebas tentang apa yang dikerjakan), ekstrak jadi poin-poin hasil kerja — bukan sekadar copy-paste commit message mentah
2. Ubah bahasa proses jadi bahasa hasil: commit message teknis seperti `fix: null pointer in order service` → di update jadi "Perbaiki bug null pointer di order service yang menyebabkan [dampak, kalau diketahui]"
3. Kelompokkan berdasarkan project/area kalau user kerja di beberapa hal sekaligus (misal: project kantor dan project freelance di hari yang sama) — pisahkan biar jelas
4. Kalau ada blocker yang disebutkan secara implisit (user cerita "masih nunggu API key dari client"), angkat eksplisit ke bagian Blockers, jangan terkubur di narasi Today

## Nada
Ringkas, hasil-oriented, hindari kalimat panjang bertele-tele. Update standup dibaca cepat oleh tim, bukan laporan naratif.
