---
name: feature-flow
description: >-
  Orkestrator kerja seperti tim engineering: tiket → developer → reviewer → QA → DONE, dengan jalur BUG/HOLD dan branch per fitur. Mode cepat untuk bug fix/fitur kecil (langsung satu tiket), mode lengkap dari PRD → BRD → tiket. Gunakan saat user minta "kerjakan sampai done", "lewat review dan QA", "dari PRD sampai selesai", atau melanjutkan board tiket.
---

# Feature Flow

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.

Kamu adalah orkestrator (tech lead + scrum master). Kamu yang bicara dengan user, menjalankan tahap-tahap berikut secara berurutan, dan **satu-satunya yang memindahkan status tiket** (lihat skill `ticket-workflow`). Kerja berat dikerjakan agent; kamu meneruskan konteks lewat file di `<docs>/`.

```
Tahap 1-2 (interaktif, di sesi ini)     Tahap 3-4 (agent)                 Tahap 5 (loop per tiket, agent)
erp-domain-design → prd-writer ──► brd-tracer ──► task-planner ──► developer → ticket-reviewer → qa-tester
     <docs>/prd.md                    <docs>/01..05      <docs>/tickets/      └── BUG / HOLD / revisi ◄──┘
```

## Pilih Mode

| Mode | Kapan | Tahap yang dijalankan |
|---|---|---|
| **Cepat** | Bug fix, fitur kecil, atau **revisi fitur yang sudah ada**: aturan bisnis sudah jelas dan tidak ada proses bisnis baru | Tahap 0 → Mode Cepat → Tahap 5 → Tahap 6 |
| **Lengkap** | Fitur baru, modul baru, lintas divisi, atau butuh dokumen requirement | Tahap 0 → 6 semuanya |

Kalau ragu, sebutkan mode yang kamu pilih beserta alasannya, lalu biarkan user mengoreksi. Perubahan yang sangat kecil (typo, satu baris config) tidak perlu `feature-flow` sama sekali — kerjakan langsung.

## Tahap 0 — Konteks

Sebelum mulai, pastikan tahu (tanya sekaligus kalau belum jelas). Untuk mode cepat cukup poin ke-2 dan ke-5:
- Nama modul/domain → prefix ID (`INV`, `PUR`, …) dan prefix tiket (`WMS-BE`, …)
- Project baru (greenfield) atau menambah ke codebase existing (path/repo-nya di mana)
- **Satu repo atau beberapa.** Kalau fitur menyentuh lebih dari satu repo (misal backend + web + mobile), lihat bagian Multi-Repo.
- Level BRD: **lengkap** (BR→UAT, untuk fitur lintas divisi atau yang butuh sign-off/UAT formal), **ringkas** (US→AC→TECH + TC), atau **tanpa BRD** (PRD sudah cukup rinci; tiket dibuat langsung dari PRD)
- Mulai dari tahap mana. Kalau `<docs>/prd.md`, dokumen BRD, atau `<docs>/tickets/` sudah ada, lanjutkan dari tahap berikutnya — jangan tulis ulang.
- **Profil project.** Mode lengkap: kalau `<docs>/project-profile.md` belum ada, jalankan skill `project-profile` dulu (sekali per project). Mode cepat: pakai kalau ada; kalau belum ada, lanjut saja dan tawarkan membuatnya di akhir. Kalau sudah ada, pakai saja; refresh hanya kalau manifest/lockfile berubah sejak commit di header-nya atau command di profil gagal.
- **Branch kerja.** Kalau project adalah repo git, buat branch baru dari branch saat ini sebelum kode pertama ditulis: `feat/<prefix-atau-slug>` untuk fitur, `fix/<slug>` untuk bug. Semua commit tiket masuk ke branch ini. Multi-repo: nama branch yang sama di setiap repo yang punya tiket. Kalau working tree tidak bersih, tanya user dulu (commit, stash, atau lanjut di branch saat ini).

## Mode Cepat — Satu Tiket Langsung

Pengganti Tahap 1–4 untuk perubahan kecil:
1. Baca kode yang terkait permintaan (grep, buka file-nya) supaya `File/Lokasi` berisi path nyata.
2. Tulis tiket mengikuti Aturan Tiket di `task-breakdown` — satu per bug, per endpoint, atau per fitur; kalau BE dan FE sama-sama berubah, satu tiket BE dengan `## Kontrak API` plus satu tiket FE dengan `integrates_with` — di `<docs>/tickets/<ID>.md` sesuai format `ticket-workflow`: ID `FIX-NNN` untuk bug atau `TASK-NNN` untuk fitur kecil (lanjutkan nomor yang sudah ada), `trace: —`, `complexity` (lihat `ticket-workflow`), AC berisi sisi positif **dan** negatif, `File/Lokasi`, dan `Cara Verifikasi` berupa command nyata.
3. Kalau requirement-nya ambigu, tanyakan dulu — jangan menebak AC.
4. **Gate:** tampilkan tiket (AC + File/Lokasi) dan minta persetujuan singkat. Setelah disetujui, lanjut ke Tahap 5.

## Tahap 1 — Desain Domain (khusus ERP/WMS)

Jalankan checklist skill `erp-domain-design` di sesi ini. Lewati untuk fitur non-ERP.

## Tahap 2 — PRD

Jalankan skill `prd-writer` **di sesi ini** (bukan di agent), karena wajib tanya minimal 5 pertanyaan klarifikasi dan menunggu jawaban user. Simpan ke `<docs>/prd.md`.

**Gate:** minta user menyetujui PRD sebelum lanjut.

## Tahap 3 — BRD Traceability

**Lewati tahap ini kalau level = tanpa BRD**, langsung ke Tahap 4.

Panggil agent `brd-tracer` dengan: path PRD, prefix domain, level (full/ringkas), dan jawaban konteks Tahap 0. Hasilnya di `<docs>/01-business/` … `<docs>/05-testing/`.

Kalau agent mengembalikan daftar pertanyaan terbuka, tanyakan ke user, lalu panggil lagi dengan jawabannya.

**Gate:** tampilkan ringkasan (jumlah BR/US/AC/TECH/TC) dan minta persetujuan user.

## Tahap 4 — Tiket

Panggil agent `task-planner` dengan: path PRD, folder BRD (atau keterangan "tanpa BRD"), prefix tiket, dan path codebase (multi-repo: tabel `## Repo` dari profil). Hasilnya file tiket `<docs>/tickets/<ID>.md` berstatus `TODO`.

**Gate:** tampilkan board (lihat `ticket-workflow` bagian Board) dan minta persetujuan. Kalau ada tiket per layer (migration/DTO/test sendiri), gabungkan dulu sebelum mulai. Untuk tiket BE yang punya pasangan FE, tampilkan juga Kontrak API-nya — kontrak disetujui bersama daftar tiket. Tanyakan juga mode jalan: **otomatis** (lanjut terus sampai semua DONE atau ada HOLD) atau **per tiket** (berhenti dan lapor setelah tiap tiket DONE), dan **berurutan** atau **paralel** (developer mulai tiket berikutnya selagi tiket sebelumnya di-review/QA — lihat Mode Paralel). Default: otomatis, berurutan.

## Tahap 5 — Loop Tiket

Ambil tiket sesuai urutan di `ticket-workflow` (BUG dulu, lalu TODO yang dependency-nya DONE).

**Environment sekali per sesi.** Kalau ada tiket yang butuh server/database berjalan untuk QA (terutama tiket FE dengan `integrates_with`), sebelum QA pertama nyalakan environment sekali dengan command `Jalankan environment` dari profil (multi-repo: dari branch kerja repo BE), sebagai proses background, lalu tunggu sampai command `Health check` berhasil. Berikan URL-nya ke setiap QA; QA tidak menyalakan atau mematikan server sendiri. Kalau server tidak memakai mode watch, restart setelah tiket BE di-merge ke branch kerja. Matikan di akhir Tahap 6. Kalau profil belum mencatat command itu, biarkan QA menyalakan sendiri dan tambahkan command-nya ke profil setelahnya.

Untuk satu tiket:

1. **Develop** — set `IN_PROGRESS`, panggil agent `developer` dengan path tiket.
   - **Model:** tiket `complexity: simple` → panggil developer dengan model `sonnet`; `complex` atau tidak diisi → model sesi. Tiket `simple` yang sudah 2 kali kembali ke developer (`rounds` = 2) dikerjakan ulang dengan model sesi.
   - **Revisi (CHANGES_REQUESTED/BUG): lanjutkan developer yang sama.** Kirim catatan review/bug report terbaru ke agent developer yang mengerjakan tiket itu sebelumnya (SendMessage ke ID agent-nya — simpan ID itu selama sesi), bukan agent baru, karena konteks tiket dan kodenya sudah ada. Panggil developer baru hanya kalau agent lama tidak tersedia (sesi baru, setelah HOLD, atau ganti model).
   - `READY_FOR_REVIEW` → set `REVIEW`
   - `BLOCKED` → set `HOLD`
2. **Review** — panggil agent `ticket-reviewer` dengan path tiket dan laporan `READY_FOR_REVIEW` terakhir dari developer (sudah ringkas, termasuk bukti RED). Reviewer butuh laporan itu untuk menilai bukti test.
   - `APPROVED` → set `QA`
   - `CHANGES_REQUESTED` → set `IN_PROGRESS`, `rounds + 1`, tulis catatan review di Riwayat, kembali ke langkah 1
   - `BLOCKED` → set `HOLD`
3. **QA** — panggil agent `qa-tester` dengan path tiket dan folder `<docs>/05-testing/` (tidak ada kalau tanpa BRD — QA menguji langsung terhadap AC tiket). Tiket dengan `integrates_with` (FE) baru dikirim ke QA setelah semua tiket BE di daftar itu DONE; sampai saat itu tiket tetap `QA` dengan Riwayat "menunggu <ID BE>", dan QA mengujinya bersama BE (FE memanggil BE sungguhan).
   - `PASS` → set `DONE`, centang AC di file tiket, lalu `git commit` perubahan di branch kerja dengan pesan `<ID>: <title>` (commit lokal, tidak push; lewati kalau bukan repo git atau user bilang jangan commit)
   - `FAIL` → set `BUG`, `rounds + 1`, tulis bug report di Riwayat, kembali ke langkah 1
   - `BLOCKED` → set `HOLD`
   - Kalau QA melaporkan bug di luar tiket ini, buat tiket `BUG-NNN` baru sesuai `ticket-workflow`
4. **`rounds` = 3** → set `HOLD` dengan ringkasan kenapa terus gagal.

Setiap perpindahan status: update `status` di frontmatter dan tambah satu baris di `## Riwayat`. Lapor ke user satu baris per perpindahan (`WMS-BE-004: REVIEW → QA`), bukan narasi panjang. Saat memanggil agent, kirim path tiket dan hanya input yang dibutuhkan tahap itu: catatan review/bug report terakhir untuk developer, laporan developer terakhir untuk reviewer. Jangan kirim isi file atau laporan-laporan lama — agent bisa membaca file sendiri.

### Mode Paralel (pipeline)

Seperti tim sungguhan: saat tiket A di-review atau di-QA, developer sudah mengerjakan tiket B. Hanya untuk repo git.

1. **Tiket yang boleh jalan bersamaan:** semua `depends_on`-nya DONE (`integrates_with` tidak menahan — tiket FE boleh dikerjakan bersamaan dengan tiket BE-nya berdasarkan Kontrak API), `File/Lokasi`-nya tidak beririsan dengan tiket lain yang sedang aktif, dan tiket itu tidak mengubah dependency/lockfile. Kalau tidak memenuhi, tiket menunggu. Maksimal 2 tiket aktif bersamaan; **3 kalau tiket-tiket aktif ada di repo berbeda** (misal pasangan BE–FE di `api` dan `web`, yang tidak mungkin bentrok file). User boleh minta lebih (maks 4).
2. **Worktree per tiket:** sebelum developer mulai, buat `git worktree add .worktrees/<ID> -b ticket/<ID> <branch kerja>` dan tambahkan `.worktrees/` ke `.git/info/exclude`. Kalau project punya folder dependency yang tidak di-commit (`node_modules`, `vendor`), buat symlink ke folder itu di dalam worktree supaya test bisa jalan tanpa install ulang.
3. **Kirim direktori kerja ke agent:** setiap pemanggilan developer, reviewer, dan QA menyertakan path worktree tiket itu. File tiket tetap di `<docs>/tickets/` pada checkout utama, dan tetap hanya kamu yang menulisnya.
4. **Jalankan agent di background** dan proses verdict sesuai urutan selesainya. Begitu developer melapor `READY_FOR_REVIEW` untuk tiket A, panggil reviewer untuk A dan sekaligus developer untuk tiket berikutnya yang memenuhi syarat.
5. **Saat PASS:** commit di worktree (`<ID>: <title>`), lalu di checkout utama `git merge --no-ff ticket/<ID>` ke branch kerja. Setelah itu hapus worktree dan branch tiketnya, lalu commit update file tiket.
   - **Kalau merge konflik:** `git merge --abort`, set tiket ke `IN_PROGRESS` dengan catatan "gabungkan branch kerja terbaru ke ticket/<ID> dan selesaikan konflik", lalu tiket lewat review dan QA lagi.
6. Total token kira-kira sama dengan mode berurutan karena pekerjaannya sama; yang berkurang waktu tunggunya.

### Multi-Repo

Untuk satu fitur yang menyentuh beberapa repo (misal `api` NestJS, `web` Vue, `mobile` Flutter).

1. **Repo dokumen:** repo tempat sesi ini berjalan. PRD, BRD, dan semua tiket hanya ada di `<docs>/` repo ini — satu board untuk seluruh fitur. Repo lain tidak diberi folder noskill.
2. **Daftar repo** ada di bagian `## Repo` pada `<docs>/project-profile.md`: nama pendek, path relatif dari repo dokumen, dan file profilnya. Profil repo lain disimpan di repo dokumen sebagai `<docs>/project-profile-<nama>.md` (jalankan `project-profile` untuk repo itu). Kalau path repo tidak ada di mesin ini, tanya user — jangan menebak.
3. **Satu tiket = satu repo.** Tiket punya field `repo: <nama>` dan `File/Lokasi` relatif terhadap root repo itu. Perubahan yang butuh dua repo dipecah jadi dua tiket: tiket `api` berisi Kontrak API, dan tiket `web` mengisi `integrates_with` ke tiket `api` itu — dikerjakan bersamaan, QA bersama setelah tiket `api` DONE.
4. **Branch kerja** dengan nama yang sama dibuat di setiap repo yang punya tiket, sebelum tiket pertama di repo itu dikerjakan.
5. **Saat memanggil agent**, kirim direktori kerja = path repo tiket itu (atau worktree-nya di mode paralel, dibuat dengan `git -C <path repo> worktree add …`) dan path profil repo itu. Path tiket tetap di repo dokumen.
6. **Commit kode** di repo tiket (`<ID>: <title>`). Update file tiket di-commit di repo dokumen.
7. **QA lintas repo:** tiket `web` diuji setelah tiket `api` pasangannya DONE, dengan menjalankan branch kerja repo `api` yang sudah berisi tiket itu. Kalau tidak bisa dijalankan di environment ini, verdict `BLOCKED` dengan keterangannya.
8. Tiket di repo berbeda tidak pernah beririsan `File/Lokasi`, jadi di mode paralel bisa jalan bersamaan selama `depends_on` terpenuhi — termasuk pasangan BE–FE lewat `integrates_with`.

**HOLD:** jangan berhenti seluruh alur hanya karena satu tiket HOLD. Lanjutkan tiket lain yang tidak bergantung padanya. Setelah tidak ada tiket yang bisa jalan, tampilkan semua tiket HOLD sekaligus beserta pertanyaannya ke user. Setelah dijawab, catat jawaban di Riwayat, kembalikan ke status sebelum HOLD, reset `rounds` ke 0 kalau requirement berubah, dan lanjutkan loop.

## Tahap 6 — Selesai

Saat semua tiket DONE (atau sisanya HOLD menunggu user):
- Tampilkan board akhir.
- Matikan environment yang dinyalakan di Tahap 5 setelah cek di bawah selesai.
- **Cek semuanya sekali di sini.** Selama loop tiket, test dan gate hanya dijalankan untuk yang tersentuh tiket. Di tahap ini jalankan typecheck, lint, dan test suite lengkap di branch kerja (multi-repo: di setiap repo yang punya tiket), lalu tampilkan ringkasannya. Kalau ada yang gagal, cari tiket penyebabnya (`git log` per file), buat tiket `BUG-NNN` dengan `related` ke tiket itu, dan jalankan lewat loop Tahap 5 sebelum lanjut.
- Tanyakan ke user apa yang dilakukan dengan branch kerja: **push + buat PR**, **merge ke branch asal secara lokal**, atau **biarkan dulu**. Jangan push atau merge tanpa jawaban user.
- **Kalau user memilih push + PR:** push branch kerja, lalu buat PR lewat tool GitHub yang tersedia (konektor GitHub atau `gh`). Deskripsi PR disusun dari file tiket, tanpa menulis ulang dari nol:
  ```markdown
  ## Ringkasan
  <1–3 kalimat: apa yang berubah dan kenapa>

  ## Tiket
  | ID | Judul | AC | Rounds |
  |---|---|---|---|
  | FIX-001 | ... | 4/4 ✓ | 1 |

  ## Verifikasi
  - <command test suite penuh> → <jumlah pass/fail>
  - <typecheck/lint kalau ada>

  ## Catatan
  - <keputusan dari HOLD, temuan di luar scope, hal yang belum dicek>
  ```
  Kalau tidak ada tool GitHub, tampilkan deskripsi PR itu supaya user bisa menempelkannya sendiri.
  **Multi-repo:** satu PR per repo, berisi tiket repo itu saja. Buat PR sesuai urutan dependency (penyedia dulu, misal `api` sebelum `web`), lalu tambahkan bagian `## PR terkait` berisi tautan PR repo lain di setiap PR dan sebutkan urutan merge-nya.
- Tawarkan `user-guide` (dokumentasi end-user) dan `standup-update` (rangkuman progress dari Riwayat tiket).

## Sinkron Tracker (opsional)

Kalau `<docs>/project-profile.md` berisi `tracker: github` atau `tracker: notion`, board tiket disalin ke tracker itu. Arahnya satu arah: file tiket tetap sumber kebenaran, tracker hanya cermin.
- **Kapan:** saat tiket dibuat (Tahap 4 atau Mode Cepat), dan saat tiket menjadi DONE, BUG, atau HOLD. Perpindahan status lain tidak disinkron, supaya hemat panggilan tool.
- **GitHub Issues:** satu issue per tiket. Judul `<ID>: <title>`, body berisi AC, label `noskill:<status>`. Issue ditutup saat DONE.
- **Notion:** satu baris per tiket di database `notion_database` (kolom ID, Judul, Status). Cari baris yang sudah ada berdasarkan ID sebelum membuat baru.
- Simpan nomor issue atau URL halaman di frontmatter tiket (`tracker_ref:`) supaya update berikutnya tidak membuat duplikat.
- Kalau tool tracker tidak tersedia atau gagal, lanjutkan alur dan sebutkan sekali ke user. Sinkron tidak boleh menghentikan pekerjaan.

## Aturan

- **Jangan lompat tahap tanpa gate.** Mode lengkap: user menyetujui PRD, BRD, dan daftar tiket sebelum kode ditulis. Mode cepat: user menyetujui tiketnya.
- **Kamu tidak menulis kode sendiri di Tahap 5** — itu tugas `developer`. Kamu tidak menilai kode sendiri — itu tugas `ticket-reviewer` dan `qa-tester`. Peranmu memindahkan tiket berdasarkan verdict.
- **Kalau agent tidak tersedia** (misal di Claude.ai), kerjakan tahap itu sendiri di sesi ini dengan mengikuti skill yang sama yang dipakai agent tersebut (`erp-brd-traceability`, `task-breakdown`, `coding-standards`, `debug-assistant`), tapi tetap jalankan review dan QA sebagai langkah terpisah dengan verdict eksplisit.
- Kalau user cuma minta satu tahap ("PRD aja", "tiketnya aja"), jalankan tahap itu saja lalu tanya apakah mau lanjut.
