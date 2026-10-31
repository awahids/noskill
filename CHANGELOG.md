# Changelog

Format: versi terbaru di atas. Versi di `.claude-plugin/plugin.json` dinaikkan setiap rilis supaya pengguna mendapat update.

## 1.9.0 — 2026-10-31

### Ditambahkan
- **`/noskill:kantor`** — Kantor noskill: diorama 3D kantor tiga lantai (Produk & Arsitektur, Engineering, Quality). Tiap agent punya meja, bisa diklik untuk melihat tugas, skill, dan pekerjaannya, dan berjalan mengantar tiket ke agent berikutnya (termasuk naik-turun tangga).
  - Di Cowork/claude.ai skill ini menerbitkan halaman sebagai artifact milik user. Di aplikasi Claude desktop dengan MCP `filesystem`, board membaca tiket asli dari satu atau beberapa folder `docs/noskill` dan menyimpan salinannya ke database artifact, supaya browser dan HP menampilkan **Snapshot**.
  - Di Claude Code tanpa artifact, halaman disalin ke folder docs dan berjalan dalam mode demo.
  - Klik tiket di board untuk melihat AC, Riwayat, siapa yang memegang, dan memutar ulang perjalanannya antar meja.
  - Panel **Metrik**: rata-rata durasi per tahap dan per agent dari baris Riwayat, tiket dengan ronde revisi terbanyak, dan daftar HOLD.
  - Filter per proyek/fitur, tombol **Ikuti tiket** (kamera mengikuti agent yang membawa tiket), panel yang bisa dikecilkan, dan daftar orang yang sedang membuka kantor.
- **Eval baru:** `developer-layer-routing`, `pm-questions-only`, `cto-arch-review` (total 19 case).

## 1.8.0 — 2026-10-31

### Ditambahkan
- **Tim engineering lengkap.** Agent baru: `product-manager` (pertanyaan klarifikasi → PRD, atau Reverse-PRD), `cto` (review arsitektur + ADR setelah PRD, dan sign-off akhir seluruh branch sebelum PR), `backend-developer`, dan `frontend-developer`.
- **Field tiket `layer`** (`be` / `fe` / `—`) memilih agent developer. Tiket lama tanpa `layer` tetap dikerjakan `developer`.
- **ADR** di `<docs>/adr/`. Keputusannya mengikat `brd-tracer`, `task-planner`, developer, dan reviewer.

### Diubah
- `feature-flow` Stage 1–2 sekarang dijalankan `product-manager` (orkestrator meneruskan pertanyaan ke user). Ada Stage 2b (CTO `ARCH_REVIEW`) dan sign-off CTO di Stage 6. Mode cepat tidak berubah.
- Prosedur developer dipindah ke skill internal `ticket-implementation` dan dipakai bersama oleh ketiga agent developer. Perilaku `developer` tidak berubah.

## 1.7.4 — 2026-10-29

### Diperbaiki
- **Plugin lolos validasi di Cowork/claude.ai.** Deskripsi skill `lazy` dan `tiket` memuat placeholder `<permintaan>`, `<deskripsi>`, dan `<ID>` yang dibaca validator sebagai tag XML sehingga plugin ditolak. Placeholder diganti dengan teks biasa (`followed by the request`, `DESKRIPSI`, `ID`), termasuk di `argument-hint` skill `tiket`.

## 1.7.3 — 2026-10-26

### Diperbaiki
- **Hook `UserPromptSubmit` kini benar-benar membaca prompt.** Sebelumnya `hooks.json` mengirim `${USER_PROMPT}` sebagai argumen, padahal placeholder itu tidak ada di Claude Code, sehingga semua prompt (termasuk laporan bug) selalu disarankan `/noskill:lazy`. `hooks/intent-router.sh` sekarang membaca field `prompt` dari JSON stdin (jq → python3 → sed sebagai cadangan).
- Router tidak memberi saran saat prompt kosong atau saat pengguna sudah mengetik slash command (`/noskill:...`).
- Kata kunci dicocokkan di awal kata, jadi `prefix` tidak lagi terdeteksi sebagai `fix` dan `ideal` tidak lagi sebagai `idea`. Frasa umum `bisa tidak` dan `next` dihapus dari kata kunci.
- Urutan deteksi: bug/error dicek lebih dulu (`fix error di fitur login` → `/noskill:tiket fix`), PRD/BRD sebelum fitur (`tulis PRD untuk modul cuti` → `/noskill:prd-writer`), dan profil project sebelum review (`cek project` sebelumnya tidak pernah sampai ke `/noskill:project-profile`).
- Matcher `SessionStart` hanya memakai nilai yang valid (`new` dihapus); matcher di `UserPromptSubmit` yang diabaikan Claude Code dihapus.

## 1.7.2 — 2026-10-25

### Diperbaiki
- Startup hook `SessionStart` makin tangguh: tidak lagi langsung `cat` satu file, tetapi memanggil wrapper startup yang memuat aturan inti dan konteks tambahan (`hooks/run-hook.sh`, `hooks/run-hook.cmd`, `hooks/startup-extra.md`).
- Menambah dukungan kompatibilitas lintas platform agar hook lebih stabil di lingkungan Unix dan Windows.
- Mengurangi kebingungan saat sesi baru dimulai karena konteks startup lebih terstruktur dan lebih jelas arah kerja noskill.

## 1.7.1 — 2026-10-18

### Diperbaiki
- Hook aturan inti kembali menyuruh **grep dulu** sebelum menulis logic helper, sekecil apa pun. Saat hook dipadatkan di 1.6.0, kalimat ini hilang, dan tanpa skill Claude sesekali menulis `Math.min` atau helper baru yang sebenarnya sudah ada di repo.

## 1.7.0 — 2026-10-17

### Diubah — skill lebih sedikit
- **Shortcut tiket digabung jadi `/noskill:tiket`.** `/noskill:board`, `/noskill:fix`, `/noskill:lanjut`, dan `/noskill:rapikan` menjadi `/noskill:tiket [board]`, `/noskill:tiket fix <deskripsi>`, `/noskill:tiket lanjut [jawaban]`, dan `/noskill:tiket rapikan [ID]`.
- **Skill internal disembunyikan dari menu `/`:** `ticket-workflow`, `task-breakdown`, `erp-requirements`, dan `coding-standards` (`user-invocable: false`). Skill ini tetap dimuat agent dan dipakai secara internal.
- **Skill tambahan pindah ke plugin `noskill-extras`:** `user-guide`, `mockup-prototype`, `standup-update`, dan `freelance-proposal` (folder `extras/`, satu marketplace). Pasang dengan `/plugin install noskill-extras@noskill`.
- **Perubahan kecil digabung jadi satu tiket.** Maksimal 3 endpoint `simple` di resource yang sama (list, detail, lookup, CRUD biasa), atau perubahan kecil di halaman/layar yang sama, jadi satu tiket.
- **Checklist AC untuk mencegah tiket BUG.** Saat menulis AC (task-planner, mode cepat, BRD), setiap input dan aturan dicek terhadap: batas angka termasuk batas kolom database, pencocokan status, validasi, dll.
- Eval baru `planner-groups-small`: endpoint GET sederhana digabung, endpoint kuota tetap sendiri dengan AC batas int4 dan case-insensitive. Aturan lama 0/3, aturan baru 3/3.
- Hasilnya, plugin inti punya 10 skill (sebelumnya 17), dan yang muncul di menu `/` tinggal 6: `feature-flow`, `tiket`, `lazy`, `project-profile`, `prd-writer`, `debug-assistant`.

## 1.6.0 — 2026-10-17

### Diubah — hemat token
- **Instruksi internal dalam bahasa Inggris.** Isi semua skill, referensi, agent, dan hook diterjemahkan ke bahasa Inggris yang ringkas. Output untuk pengguna tetap berbahasa Indonesia: jawaban, PRD, dan laporan.
- **Deskripsi skill dan agent lebih ringkas** (±2,6k → ±1,9k token, −28%). Deskripsi dimuat di setiap sesi, dan frasa pemicu dalam bahasa Indonesia tetap ada.
- **Hook aturan inti dipadatkan** (±925 → ±570 token, −39%), juga dimuat di setiap sesi. Isinya sama, ditambah aturan bahasa: tulis untuk pengguna dalam bahasa Indonesia kecuali pengguna menulis dalam bahasa lain.
- **QA lebih hemat.** QA tidak lagi menyalakan DB/container, menerapkan schema/migrasi, atau memasang dependency sendiri. Kalau URL environment tidak diberikan, QA langsung menjawab `BLOCKED: environment missing`.
- **Refresh profil melengkapi profil lama.** `project-profile` saat refresh menambahkan baris yang belum ada di profil lama (`Jalankan environment`, `Health check`, command cepat per tiket) tanpa menghapus detail yang sudah ada.
- Eval baru `qa-env-missing`: tiket FE dengan `integrates_with` tanpa URL environment harus BLOCKED tanpa menjalankan script environment atau migrasi. Versi QA lama menyalakan environment sendiri dan sering mengubah state.
- README skill (`skills/*/README.md`) dan contoh `example-goods-receipt.md` tetap berbahasa Indonesia karena dibaca manusia, bukan dimuat agent.

## 1.5.0 — 2026-10-16

### Diubah — agent lebih ringan
- `coding-standards` dirampingkan (23,4k → 18,2k karakter): contoh kode fungsi/TDD, anti-pattern test, dan simplify pass pindah ke `references/functions-tdd.md`; Git, secrets, dan changelog pindah ke referensi ringkas.
- Developer, reviewer, dan QA tidak lagi memuat `ticket-workflow` (±8k karakter) — verdict dan aturan yang mereka butuhkan sudah ada di definisi agent masing-masing. `task-planner` tetap memuat ticket-workflow.
- `brd-tracer` level ringkas hanya menulis `03-functional/`, `04-technical/`, dan `05-testing/` (tanpa `01-business/`, `02-process/`, atau UAT) — sebelumnya sesekali ikut membuat `01-business/`.
- Bagian baru `## Catatan` di tiket: orkestrator (mode cepat) dan `task-planner` mencatat helper yang bisa dipakai ulang, file contoh pola, dan test yang sudah ada. Developer mulai dari catatan itu saat mengerjakan tiket.

### Ditambahkan — eval
- `qa-fails-negative`, `qa-passes-correct`: QA menolak implementasi yang AC negatifnya gagal, meloloskan yang benar, tidak mengubah kode, dan menulis laporan.
- `rapikan-apply`: penggabungan tiket setelah disetujui, asal tiket dicatat, tiket DONE tidak disentuh, perubahan di-commit.
- `rapikan-review`: review ulang tiket DONE menghasilkan tiket BUG baru, tiket asal tetap DONE.
- `brd-tracer-ringkas`: PRD → dokumen BRD level ringkas dengan skill `erp-requirements`.

## 1.4.0 — 2026-10-16

### Diubah — lebih cepat dan lebih ringan
- **Command cepat dengan cache.** `project-profile` mencatat versi cepat untuk per tiket: `tsc --incremental`, `eslint --cache` (cache di `.noskill-cache/`, dikecualikan lewat `.git/info/exclude`).
- **Laporan agent ke file.** Developer, reviewer, dan QA menulis laporan lengkap ke `<docs>/reports/<ID>/dev|review|qa-<putaran>.md` dan menjawab orkestrator maksimal 6 baris (verdict, ringkasan, hasil test).
- **Jam di Riwayat dan durasi di board.** Riwayat ditulis dengan `YYYY-MM-DD HH:MM`. `/noskill:board` menghitung menit per tiket di tahap developer, review, dan QA, rata-rata per tahap, dan tahap selesai.

### Ditambahkan
- Logo noskill: huruf **n** yang sekaligus jalur kerja tiket — titik biru (developer), kuning (reviewer), dan centang (QA lolos/DONE). File: `docs/logo.svg` (ikon), `docs/logo-wordmark.svg` / `docs/logo-wordmark-dark.svg` (wordmark).

## 1.3.0 — 2026-10-15

### Ditambahkan
- Shortcut `/noskill:lazy` (lazy senior dev mode): langsung kerjakan solusi paling sederhana dan terpendek yang jalan — YAGNI, stdlib dulu, tanpa abstraksi yang tidak diminta — tanpa tiket, review, atau QA.
- Halaman `docs/skills.html`: penjelasan detail setiap skill.
- Shortcut `/noskill:rapikan`: merapikan tiket TODO/HOLD yang sudah dibuat agar sesuai aturan tiket terbaru (gabung tiket per layer, pecah yang terlalu besar, lengkapi Kontrak API, `integrates_with`, `complexity`).

### Diubah — skill digabung
- `erp-domain-design` dan `erp-brd-traceability` digabung menjadi `erp-requirements` (Bagian A: desain domain, Bagian B: BRD traceability). Agent `brd-tracer` sekarang memuat satu skill ini.
- `api-doc-standard` dipindah ke `coding-standards` sebagai `references/api-doc.md`, dibaca saat tiket menyentuh endpoint.
- Jumlah skill: 18 → 17 (termasuk dua shortcut baru).

## 1.2.0 — 2026-10-15

### Diubah — tiket lebih cepat
- Test dan quality gate tidak lagi dijalankan tiga kali per tiket. Developer menjalankannya sekali, terbatas pada file yang tersentuh (lint file yang diubah, test terkait). Reviewer tidak menjalankan ulang test, cukup menilai kualitas patch dan AC.
- `ticket-reviewer` dan `qa-tester` memakai Sonnet. `developer` tetap memakai model sesi.
- Reviewer hanya membaca bagian dokumen requirement yang dirujuk `trace`.
- Profil project mencatat command "test terkait file" dan "lint file tertentu".
- Typecheck, lint, dan suite penuh dijalankan sekali di Tahap 6. Kalau gagal, dibuat tiket BUG untuk tiket penyebabnya.

### Diubah — alur tiket lebih efisien
- Revisi (CHANGES_REQUESTED/BUG) dilanjutkan oleh agent developer yang sama lewat SendMessage, jadi tiket, profil, dan kode tidak dibaca ulang. Developer baru hanya kalau agent lama tidak tersedia.
- Field tiket `complexity: simple | complex`. Tiket `simple` dikerjakan developer dengan Sonnet; `complex` dengan model sesi. Tiket `simple` yang sudah 2 kali kembali ke developer pindah ke model lebih kuat.
- Environment (DB + server BE) dinyalakan sekali per sesi sebelum QA pertama yang membutuhkannya, dipakai bersama oleh semua QA, dan dimatikan di akhir. Profil project mencatat command `Jalankan environment`.
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
- **Multi-repo:** satu fitur bisa menyentuh beberapa repo. Daftar repo di bagian `## Repo` pada `project-profile.md`, profil repo lain di `project-profile-<nama>.md`, field tiket `repo:`, branch baru, dan PR tetap di repo asal.
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
