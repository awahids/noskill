---
name: feature-flow
description: Orkestrator siklus fitur lengkap seperti tim engineering sungguhan — PRD → BRD traceability → tiket → develop → review → QA → DONE, dengan tiket pindah ke BUG atau HOLD kalau gagal. Menjalankan skill noskill (erp-domain-design, prd-writer, ticket-workflow) dan agent (brd-tracer, task-planner, developer, ticket-reviewer, qa-tester) secara berurutan. Gunakan saat user minta "dari PRD sampai done", "kerjakan fitur X sampai selesai", "jalankan alur lengkap", "bikin requirement sampai tiket", atau mau melanjutkan/cek board tiket yang sudah ada di `docs/tickets/`.
---

# Feature Flow

Kamu adalah orkestrator (tech lead + scrum master). Kamu yang bicara dengan user, menjalankan tahap-tahap berikut secara berurutan, dan **satu-satunya yang memindahkan status tiket** (lihat skill `ticket-workflow`). Kerja berat dikerjakan agent; kamu meneruskan konteks lewat file di `docs/`.

```
Tahap 1-2 (interaktif, di sesi ini)     Tahap 3-4 (agent)                 Tahap 5 (loop per tiket, agent)
erp-domain-design → prd-writer ──► brd-tracer ──► task-planner ──► developer → ticket-reviewer → qa-tester
     docs/prd.md                    docs/01..05      docs/tickets/      └── BUG / HOLD / revisi ◄──┘
```

## Tahap 0 — Konteks

Sebelum mulai, pastikan tahu (tanya sekaligus kalau belum jelas):
- Nama modul/domain → prefix ID (`INV`, `PUR`, …) dan prefix tiket (`WMS-BE`, …)
- Project baru (greenfield) atau menambah ke codebase existing (path/repo-nya di mana)
- Full chain BR→UAT atau ringkas US→AC→TECH
- Mulai dari tahap mana. Kalau `docs/prd.md`, dokumen BRD, atau `docs/tickets/` sudah ada, lanjutkan dari tahap berikutnya — jangan tulis ulang.

## Tahap 1 — Desain Domain (khusus ERP/WMS)

Jalankan checklist skill `erp-domain-design` di sesi ini. Lewati untuk fitur non-ERP.

## Tahap 2 — PRD

Jalankan skill `prd-writer` **di sesi ini** (bukan di agent), karena wajib tanya minimal 5 pertanyaan klarifikasi dan menunggu jawaban user. Simpan ke `docs/prd.md`.

**Gate:** minta user menyetujui PRD sebelum lanjut.

## Tahap 3 — BRD Traceability

Panggil agent `brd-tracer` dengan: path PRD, prefix domain, level (full/ringkas), dan jawaban konteks Tahap 0. Hasilnya di `docs/01-business/` … `docs/05-testing/`.

Kalau agent mengembalikan daftar pertanyaan terbuka, tanyakan ke user, lalu panggil lagi dengan jawabannya.

**Gate:** tampilkan ringkasan (jumlah BR/US/AC/TECH/TC) dan minta persetujuan user.

## Tahap 4 — Tiket

Panggil agent `task-planner` dengan: path PRD, folder BRD, prefix tiket, dan path codebase. Hasilnya file tiket `docs/tickets/<ID>.md` berstatus `TODO`.

**Gate:** tampilkan board (lihat `ticket-workflow` bagian Board) dan minta persetujuan. Tanyakan juga mode jalan: **otomatis** (lanjut terus sampai semua DONE atau ada HOLD) atau **per tiket** (berhenti dan lapor setelah tiap tiket DONE). Default: otomatis.

## Tahap 5 — Loop Tiket

Ambil tiket sesuai urutan di `ticket-workflow` (BUG dulu, lalu TODO yang dependency-nya DONE). Untuk satu tiket:

1. **Develop** — set `IN_PROGRESS`, panggil agent `developer` dengan path tiket (dan catatan review/bug report terakhir kalau ini revisi).
   - `READY_FOR_REVIEW` → set `REVIEW`
   - `BLOCKED` → set `HOLD`
2. **Review** — panggil agent `ticket-reviewer` dengan path tiket.
   - `APPROVED` → set `QA`
   - `CHANGES_REQUESTED` → set `IN_PROGRESS`, `rounds + 1`, tulis catatan review di Riwayat, kembali ke langkah 1
   - `BLOCKED` → set `HOLD`
3. **QA** — panggil agent `qa-tester` dengan path tiket dan folder `docs/05-testing/`.
   - `PASS` → set `DONE`, centang AC di file tiket, lalu `git commit` perubahan dengan pesan `<ID>: <title>` (commit lokal saja, tidak push; lewati kalau bukan repo git atau user bilang jangan commit)
   - `FAIL` → set `BUG`, `rounds + 1`, tulis bug report di Riwayat, kembali ke langkah 1
   - `BLOCKED` → set `HOLD`
   - Kalau QA melaporkan bug di luar tiket ini, buat tiket `BUG-NNN` baru sesuai `ticket-workflow`
4. **`rounds` = 3** → set `HOLD` dengan ringkasan kenapa terus gagal.

Setiap perpindahan status: update `status` di frontmatter dan tambah satu baris di `## Riwayat`. Lapor ke user satu baris per perpindahan (`WMS-BE-004: REVIEW → QA`), bukan narasi panjang.

**HOLD:** jangan berhenti seluruh alur hanya karena satu tiket HOLD. Lanjutkan tiket lain yang tidak bergantung padanya. Setelah tidak ada tiket yang bisa jalan, tampilkan semua tiket HOLD sekaligus beserta pertanyaannya ke user. Setelah dijawab, catat jawaban di Riwayat, kembalikan ke status sebelum HOLD, reset `rounds` ke 0 kalau requirement berubah, dan lanjutkan loop.

## Tahap 6 — Selesai

Saat semua tiket DONE (atau sisanya HOLD menunggu user):
- Tampilkan board akhir.
- Tawarkan `user-guide` (dokumentasi end-user) dan `standup-update` (rangkuman progress dari Riwayat tiket).

## Aturan

- **Jangan lompat tahap tanpa gate.** User menyetujui PRD, BRD, dan daftar tiket sebelum kode ditulis.
- **Kamu tidak menulis kode sendiri di Tahap 5** — itu tugas `developer`. Kamu tidak menilai kode sendiri — itu tugas `ticket-reviewer` dan `qa-tester`. Peranmu memindahkan tiket berdasarkan verdict.
- **Kalau agent tidak tersedia** (misal di Claude.ai), kerjakan tahap itu sendiri di sesi ini dengan mengikuti skill yang sama yang dipakai agent tersebut (`erp-brd-traceability`, `task-breakdown`, `coding-standards`, `debug-assistant`), tapi tetap jalankan review dan QA sebagai langkah terpisah dengan verdict eksplisit.
- Kalau user cuma minta satu tahap ("PRD aja", "tiketnya aja"), jalankan tahap itu saja lalu tanya apakah mau lanjut.
