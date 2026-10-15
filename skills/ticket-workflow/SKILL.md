---
name: ticket-workflow
description: >-
  Format file tiket noskill dan alur statusnya (TODO → IN_PROGRESS → REVIEW → QA → DONE, plus BUG dan HOLD), verdict agent, dan board. Gunakan saat membuat, memindahkan, atau melaporkan tiket, atau user tanya status/board tiket.
---

# Ticket Workflow

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.

Kontrak bersama untuk semua tiket di `<docs>/tickets/`. Semua skill dan agent yang menyentuh tiket mengikuti aturan di sini, supaya status tiket punya satu arti yang sama di semua tahap.

## Alur Status

```
TODO ──► IN_PROGRESS ──► REVIEW ──► QA ──► DONE
              ▲             │        │
              │   revisi    │        │ gagal test
              ├─────────────┘        ▼
              └──────────────────── BUG

Status apa pun ──► HOLD  (butuh keputusan user / blocker eksternal)
HOLD ──► status sebelum HOLD, setelah blocker selesai
```

| Status | Arti | Siapa yang memproses | Keluar ke |
|---|---|---|---|
| `TODO` | Siap dikerjakan, semua `depends_on` sudah DONE | developer | IN_PROGRESS |
| `IN_PROGRESS` | Sedang dikerjakan / direvisi | developer | REVIEW, HOLD |
| `REVIEW` | Kode selesai, dicek kesesuaian dengan tiket | ticket-reviewer | QA, IN_PROGRESS, HOLD |
| `QA` | Lolos review, dites terhadap AC & Test Case | qa-tester | DONE, BUG, HOLD |
| `BUG` | Gagal QA — ada bug report di Riwayat | developer (pakai `debug-assistant`) | IN_PROGRESS |
| `HOLD` | Berhenti: requirement ambigu, butuh keputusan user, environment/akses tidak tersedia, atau sudah 3 putaran gagal | user | status sebelumnya |
| `DONE` | Lolos QA, perubahan sudah di-commit | — | — |

## Aturan Transisi

1. **Hanya orkestrator (`feature-flow`) yang mengubah field `status`, `rounds`, dan menulis `## Riwayat`.** Agent lain mengembalikan verdict; orkestrator yang memindahkan tiket. Satu penulis = tidak ada status yang saling timpa.
2. **Satu tiket per direktori kerja**, supaya `git diff` saat review/QA hanya berisi perubahan tiket itu. Mode berurutan: semua tiket bergantian di branch kerja. Mode paralel: tiap tiket aktif punya git worktree sendiri. Multi-repo: tiket dikerjakan di repo yang ditulis di field `repo` (lihat `feature-flow`).
3. **Urutan ambil tiket:** `BUG` dulu, lalu `TODO` yang semua `depends_on`-nya sudah DONE, urut ID. Tiket yang depend ke tiket HOLD tidak diambil.
4. **`rounds` naik 1** setiap tiket kembali ke developer (REVIEW → IN_PROGRESS atau QA → BUG). Kalau `rounds` mencapai 3, tiket pindah ke **HOLD** — tiga putaran gagal berarti masalahnya di requirement/desain, bukan di kode, dan butuh keputusan user.
5. **Tidak ada status yang dilompati.** Tidak ada tiket langsung dari IN_PROGRESS ke QA, atau dari REVIEW ke DONE.
6. **DONE butuh bukti.** QA hanya boleh PASS kalau setiap AC dan TC tiket benar-benar dijalankan dan hasilnya terlihat (output test/command), bukan "seharusnya benar".

## Verdict Agent

Agent mengembalikan verdict di baris pertama jawabannya, lalu detail:

| Agent | Verdict | Status berikutnya |
|---|---|---|
| developer | `READY_FOR_REVIEW` | REVIEW |
| developer | `BLOCKED: <alasan>` | HOLD |
| ticket-reviewer | `APPROVED` | QA |
| ticket-reviewer | `CHANGES_REQUESTED` + daftar perubahan | IN_PROGRESS |
| ticket-reviewer | `BLOCKED: <alasan>` | HOLD |
| qa-tester | `PASS` + bukti per AC/TC | DONE |
| qa-tester | `FAIL` + bug report | BUG |
| qa-tester | `BLOCKED: <alasan>` | HOLD |

`BLOCKED` hanya untuk hal yang tidak bisa diselesaikan agent sendiri (requirement bertentangan/ambigu, akses/env tidak ada, keputusan bisnis). Kode yang salah bukan BLOCKED — itu CHANGES_REQUESTED atau FAIL.

## Format File Tiket

Satu file per tiket: `<docs>/tickets/<ID>.md`. ID mengikuti aturan penomoran `task-breakdown` (misal `WMS-BE-004`); bug baru dari QA pakai `BUG-NNN`. Satu tiket hanya mengubah satu repo.

```markdown
---
id: WMS-BE-004
title: Validasi outstanding quantity saat Goods Receipt
type: task            # task | bug
repo: api             # opsional, hanya untuk fitur multi-repo: nama repo dari bagian Repo di project-profile
status: TODO
trace: US-INV-001 / TECH-003   # dari erp-brd-traceability, "—" kalau tidak ada
ac: [AC-002]
tc: [TC-INV-002]
depends_on: [WMS-BE-001]
related: []           # untuk tiket bug: tiket asal
rounds: 0
tracker_ref: —        # opsional: nomor issue GitHub / URL Notion kalau tracker aktif
---

## Deskripsi
[apa yang dikerjakan, 1-3 kalimat]

## Acuan
[section PRD / dokumen BRD terkait]

## File/Lokasi
[path konkret di project — multi-repo: relatif terhadap root repo tiket]

## Acceptance Criteria
- [ ] AC-002: Received qty > outstanding qty → transaksi ditolak

## Cara Verifikasi
[command/langkah konkret yang membuktikan tiket selesai]

## Riwayat
- 2026-10-14 TODO — dibuat oleh task-planner
```

**Riwayat** ditulis append-only, satu baris per perpindahan status: `- <tanggal> <STATUS> — <ringkasan alasan>`. Untuk perpindahan ke BUG/HOLD/IN_PROGRESS (revisi), tambahkan detail di bawahnya (indent) — catatan review, bug report, atau pertanyaan untuk user.

## Bug Report (QA → BUG)

```markdown
- 2026-10-14 BUG — TC-INV-002 gagal
  - **Langkah:** POST /api/v1/goods-receipts dengan outstanding=30, received=40
  - **Expected:** 422, transaksi ditolak
  - **Actual:** 201, GR tersimpan
  - **Bukti:** [output command/test]
```

Kalau QA menemukan bug **di luar AC tiket ini** (regresi di fitur lain), jangan gagalkan tiket ini karenanya — buat tiket baru `type: bug`, `status: BUG`, `related: [<tiket asal>]`. Kalau perilaku yang benar untuk bug itu belum ditentukan di requirement (tidak ada AC yang bisa jadi Expected), status awalnya `HOLD` dengan pertanyaan ke user, bukan `BUG` — developer tidak bisa memperbaiki tanpa spesifikasi.

## Board

Tampilkan board dari field `status` semua file tiket (`grep -H "^status:" <docs>/tickets/*.md`), dikelompokkan per kolom: TODO · IN_PROGRESS · REVIEW · QA · BUG · HOLD · DONE. Multi-repo: tulis repo di samping ID (`WMS-FE-002 [web]`). Board tidak disimpan sebagai file terpisah — file tiket adalah satu-satunya sumber kebenaran.
