# Changelog

Format: versi terbaru di atas. Versi di `.claude-plugin/plugin.json` dinaikkan setiap rilis supaya pengguna mendapat update.

## 1.4.0 — 2026-10-16

### Diubah — lebih cepat dan lebih ringan
- **Command cepat dengan cache.** `project-profile` mencatat versi cepat untuk per tiket: `tsc --incremental`, `eslint --cache` (cache di `.noskill-cache/`, dikecualikan lewat `.git/info/exclude`), `jest --findRelatedTests` / `vitest related`. Developer memakainya untuk quality gate per tiket.
- **Laporan agent ke file.** Developer, reviewer, dan QA menulis laporan lengkap ke `<docs>/reports/<ID>/dev|review|qa-<putaran>.md` dan menjawab orkestrator maksimal 6 baris (verdict, ringkasan, path). Agent berikutnya membaca laporan dari file. Sesi utama tetap ringan di fitur dengan banyak tiket, dan Riwayat tiket cukup merujuk path laporan.
- **Jam di Riwayat dan durasi di board.** Riwayat ditulis dengan `YYYY-MM-DD HH:MM`. `/noskill:board` menghitung menit per tiket di tahap developer, review, dan QA, rata-rata per tahap, dan tahap yang paling lama.

### Ditambahkan
- Logo noskill (`docs/logo.svg`, `docs/logo.png` 512px): tiket dengan tanda centang. Dipakai di README, favicon, dan navigasi halaman docs.

## 1.3.0 — 2026-10-15

### Ditambahkan
- Shortcut `/noskill:lazy` (lazy senior dev mode): langsung kerjakan solusi paling sederhana dan terpendek yang jalan — YAGNI, stdlib dulu, tanpa abstraksi yang tidak diminta — tanpa tiket, review, atau QA. Tetap wajib bukti test, dan berhenti lalu menyarankan `/noskill:fix` atau `/noskill:feature-flow` kalau ternyata menyentuh aturan bisnis baru, skema, lebih dari ±5 file, atau beberapa repo.
- Halaman `docs/skills.html`: penjelasan detail setiap skill.
- Shortcut `/noskill:rapikan`: merapikan tiket TODO/HOLD yang sudah dibuat agar sesuai aturan tiket terbaru (gabung tiket per layer, pecah yang terlalu besar, lengkapi Kontrak API, `integrates_with`, `complexity`, AC negatif, File/Lokasi nyata). Usulan ditampilkan dulu dan baru diterapkan setelah disetujui. `/noskill:rapikan review <ID>` mereview ulang commit tiket DONE; temuan jadi tiket BUG baru.

### Diubah — skill digabung
- `erp-domain-design` dan `erp-brd-traceability` digabung menjadi `erp-requirements` (Bagian A: desain domain, Bagian B: BRD traceability). Agent `brd-tracer` sekarang memuat satu skill ini.
- `api-doc-standard` dipindah ke `coding-standards` sebagai `references/api-doc.md`, dibaca saat tiket menyentuh endpoint.
- Jumlah skill: 18 → 17 (termasuk dua shortcut baru).

## 1.2.0 — 2026-10-15

### Diubah — tiket lebih cepat
- Test dan quality gate tidak lagi dijalankan tiga kali per tiket. Developer menjalankannya sekali, terbatas pada file yang tersentuh (lint file yang diubah, test terkait). Reviewer tidak menjalankan ulang. QA menjalankan test tiket dan test terkait sekali. Suite penuh hanya sekali di akhir fitur.
- `ticket-reviewer` dan `qa-tester` memakai Sonnet. `developer` tetap memakai model sesi.
- Reviewer hanya membaca bagian dokumen requirement yang dirujuk `trace`.
- Profil project mencatat command "test terkait file" dan "lint file tertentu".
- Typecheck, lint, dan suite penuh dijalankan sekali di Tahap 6. Kalau gagal, dibuat tiket BUG untuk tiket penyebabnya.

### Diubah — alur tiket lebih efisien
- Revisi (CHANGES_REQUESTED/BUG) dilanjutkan oleh agent developer yang sama lewat SendMessage, jadi tiket, profil, dan kode tidak dibaca ulang. Developer baru hanya kalau agent lama tidak tersedia.
- Field tiket `complexity: simple | complex`. Tiket `simple` dikerjakan developer dengan Sonnet; `complex` dengan model sesi. Tiket `simple` yang sudah 2 kali kembali ke developer pindah ke model sesi.
- Environment (DB + server BE) dinyalakan sekali per sesi sebelum QA pertama yang membutuhkannya, dipakai bersama oleh semua QA, dan dimatikan di akhir. Profil project mencatat command `Jalankan environment` dan `Health check`.
- Mode paralel: maksimal 3 tiket aktif kalau tiketnya ada di repo berbeda (misal pasangan BE–FE), tetap 2 kalau satu repo.

### Diubah — aturan tiket lebih sederhana
- Satu tiket per endpoint (BE), per fitur/halaman (FE), atau per bug. Migration, DTO, test, dan Swagger ikut ke tiket endpoint/fitur yang membutuhkannya, tidak ada tiket per layer.
- Tiket BE yang menambah/mengubah endpoint memuat `## Kontrak API` (method + path, request + validasi, response sukses, response error + kode) sejak tiket dibuat.
- Field baru `integrates_with`: tiket FE merujuk tiket BE yang kontraknya dipakai. FE boleh dikerjakan bersamaan dengan BE; QA tiket FE menunggu BE DONE lalu menguji FE dan BE bersama.
- Kontrak tidak diubah diam-diam: perubahan kontrak lewat `BLOCKED` dan dicatat orkestrator di Riwayat kedua tiket. Reviewer mengecek implementasi sama persis dengan kontrak.
- Revisi fitur yang sudah ada masuk mode cepat.
- Eval planner mengecek jumlah tiket, Kontrak API di tiket BE, dan `integrates_with` di tiket FE.

## 1.1.0 — 2026-10-15

### Ditambahkan
- **Opsi tanpa BRD** di mode lengkap: tiket dibuat langsung dari PRD, AC positif/negatif ditulis di tiket (`trace: —`, `tc: []`), QA menguji langsung terhadap AC.
- **Multi-repo:** satu fitur bisa menyentuh beberapa repo. Daftar repo di bagian `## Repo` pada `project-profile.md`, profil repo lain di `project-profile-<nama>.md`, field tiket `repo:`, branch kerja bernama sama di tiap repo, satu PR per repo yang saling menautkan. PRD, BRD, dan tiket tetap di satu repo.
- Eval baru: `planner-no-brd`, `planner-multi-repo`, `developer-worktree` (mode paralel).
- `CHANGELOG.md`.

### Diubah
- Contoh di skill memakai kasus netral (Kantin/HRIS, web donasi), bukan nama project pribadi.
- Agent membaca profil yang diberikan orkestrator (profil repo tiket di fitur multi-repo).

## 1.0.0 — 2026-10-14

Rilis pertama sebagai plugin mandiri `noskill`.

- Alur tiket seperti tim engineering lewat `feature-flow`: developer → ticket-reviewer → qa-tester → DONE, dengan jalur BUG dan HOLD, maksimal 3 putaran.
- Mode cepat (satu tiket untuk bug fix/fitur kecil) dan mode lengkap (PRD → BRD → tiket).
- Mode paralel dengan git worktree per tiket.
- Aturan inti lewat hook SessionStart: scope ketat, pikir dulu, solusi paling sederhana, reuse, test positif/negatif/batas, kode efisien, hemat token.
- Skill `project-profile`, shortcut (`board`, `lanjut`, `fix`), sinkron tracker GitHub/Notion, folder hasil yang bisa diatur (`docs_dir`, default `docs/noskill`).
- Agent dokumen (`brd-tracer`, `task-planner`) memakai Sonnet.
- Dokumentasi di GitHub Pages, lisensi MIT, siap untuk marketplace dan direktori plugin.
