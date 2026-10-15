# Changelog

Format: versi terbaru di atas. Versi di `.claude-plugin/plugin.json` dinaikkan setiap rilis supaya pengguna mendapat update.

## 1.2.0 — 2026-10-15

### Diubah — tiket lebih cepat
- Test dan quality gate tidak lagi dijalankan tiga kali per tiket. Developer menjalankannya sekali, terbatas pada file yang tersentuh (lint file yang diubah, test terkait). Reviewer tidak menjalankan ulang. QA menjalankan test tiket dan test terkait sekali. Suite penuh hanya sekali di akhir fitur.
- `ticket-reviewer` dan `qa-tester` memakai Sonnet. `developer` tetap memakai model sesi.
- Reviewer hanya membaca bagian dokumen requirement yang dirujuk `trace`.
- Profil project mencatat command "test terkait file" dan "lint file tertentu".
- Typecheck, lint, dan suite penuh dijalankan sekali di Tahap 6. Kalau gagal, dibuat tiket BUG untuk tiket penyebabnya.

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
