<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/logo-wordmark-dark.svg">
    <img src="docs/logo-wordmark.svg" width="300" alt="noskill">
  </picture>
</p>

# noskill

Koleksi Claude Skills & Agent untuk kerja development sehari-hari — dipaketkan sebagai plugin `noskill`, termasuk alur tiket lengkap (develop → review → QA) dengan agent.

📖 **Dokumentasi lengkap:** [awahids.github.io/noskill](https://awahids.github.io/noskill/) (sumber: [`docs/index.html`](docs/index.html)) — cara install, cara kerja alur tiket, semua skill & agent, shortcut, dan konfigurasi.

## Skills

Penjelasan detail tiap skill (kapan dipakai, langkah kerja, hasil, aturan penting): **[awahids.github.io/noskill/skills.html](https://awahids.github.io/noskill/skills.html)** (sumber: [`docs/skills.html`](docs/skills.html)).

| Skill | Fungsi |
|---|---|
| [`feature-flow`](skills/feature-flow/) | Orkestrator: tiket → developer → reviewer → QA → DONE (atau BUG/HOLD). Mode cepat dan lengkap, paralel, multi-repo, branch dan PR |
| [`ticket-workflow`](skills/ticket-workflow/) | Format file tiket, arti tiap status, aturan transisi, verdict agent, dan board |
| [`project-profile`](skills/project-profile/) | Scan repo sekali → `docs/noskill/project-profile.md` (stack, command, struktur, helper, aturan) yang dibaca semua agent |
| [`lazy`](skills/lazy/) · [`fix`](skills/fix/) · [`board`](skills/board/) · [`lanjut`](skills/lanjut/) · [`rapikan`](skills/rapikan/) | Shortcut: kerjakan langsung dengan solusi paling sederhana, bug fix lewat mode cepat, lihat board tiket, lanjutkan tiket dari sesi sebelumnya, rapikan tiket lama atau review ulang tiket DONE |
| [`prd-writer`](skills/prd-writer/) | PRD baku dengan diagram Mermaid, didahului minimal 5 pertanyaan klarifikasi; juga Reverse-PRD dari kode |
| [`erp-requirements`](skills/erp-requirements/) | ERP/WMS: (A) checklist desain domain — master data, stock ledger, workflow status, RBAC, audit trail, roadmap MVP; (B) rantai requirement BR → PROC → US → AC → TECH → TC → UAT dengan ID yang bisa ditelusuri |
| [`task-breakdown`](skills/task-breakdown/) | PRD/BRD → tiket: satu per endpoint (BE, dengan Kontrak API), per fitur (FE), atau per bug |
| [`mockup-prototype`](skills/mockup-prototype/) | Mockup/prototype UI dari PRD, per layar dan per role, termasuk state loading/kosong/error |
| [`coding-standards`](skills/coding-standards/) | Naming, struktur folder, ORM, API, dokumentasi Swagger/OpenAPI, TDD, quality gate, dan checklist review untuk NestJS/Laravel/Golang/Vue/Next.js |
| [`debug-assistant`](skills/debug-assistant/) | Debugging terstruktur: reproduce → isolasi → root cause → fix → verifikasi dengan bukti |
| [`user-guide`](skills/user-guide/) | Panduan pengguna non-teknis per role dan per fitur |
| [`standup-update`](skills/standup-update/) | Standup harian atau laporan mingguan, dibaca dari Riwayat tiket |
| [`freelance-proposal`](skills/freelance-proposal/) | Proposal project per fase dengan harga Rupiah dan syarat pembayaran |

## Agent

Dipanggil oleh `feature-flow`. Tiap agent memuat skill yang relevan lewat field `skills:`.

| Agent | Peran | Skill yang dimuat | Bisa ubah kode? |
|---|---|---|---|
| [`brd-tracer`](agents/brd-tracer.md) | PRD → BR/PROC/US/AC/TECH/TC di `docs/noskill/01..05` | `erp-requirements` | Tidak (hanya tulis dokumen) |
| [`task-planner`](agents/task-planner.md) | BRD → file tiket `docs/noskill/tickets/*.md` status TODO | `task-breakdown`, `ticket-workflow` | Tidak (hanya tulis tiket) |
| [`developer`](agents/developer.md) | Kerjakan satu tiket / fix BUG sampai Cara Verifikasi lolos | `coding-standards`, `debug-assistant`, `ticket-workflow` | Ya |
| [`ticket-reviewer`](agents/ticket-reviewer.md) | Cek perubahan sesuai AC tiket & standar → APPROVED / CHANGES_REQUESTED / BLOCKED | `coding-standards`, `ticket-workflow` | Tidak |
| [`qa-tester`](agents/qa-tester.md) | Jalankan test terhadap AC & TC → PASS / FAIL (bug report) / BLOCKED | `ticket-workflow` | Tidak |

## Aturan inti yang selalu aktif

Plugin ini memasang hook `SessionStart` ([`hooks/core-rules.md`](hooks/core-rules.md)) yang memuat ±10 baris aturan kerja ke setiap sesi, juga saat tidak ada skill yang dipanggil: ubah hanya yang diminta, pikir dulu, solusi paling sederhana, reuse helper yang ada, test positif/negatif/batas dengan bukti RED, klaim selesai hanya dengan bukti. Detail lengkapnya tetap ada di `coding-standards`.

## Folder hasil

Semua dokumen yang dihasilkan (PRD, BRD `01..05`, tiket, profil project) ditulis ke `docs/noskill/` secara default. Untuk mengganti, buka `/config` dan ubah opsi **Folder dokumen noskill** milik plugin noskill, atau isi di `~/.claude/settings.json`:

```json
{ "pluginConfigs": { "noskill@noskill": { "options": { "docs_dir": "docs" } } } }
```

Pengaturan ini berlaku untuk semua project di komputer itu.

## Shortcut

| Perintah | Fungsi |
|---|---|
| `/noskill:rapikan [ID]` | Rapikan tiket TODO/HOLD agar sesuai aturan tiket terbaru (gabung tiket per layer, lengkapi Kontrak API, `integrates_with`, `complexity`); usulan ditampilkan dulu sebelum diterapkan |
| `/noskill:rapikan review <ID>` | Review ulang kode tiket DONE; temuan jadi tiket BUG baru |
| `/noskill:lazy <permintaan>` | Lazy senior dev mode: langsung kerjakan solusi paling sederhana dan terpendek yang jalan (YAGNI, stdlib dulu, tanpa abstraksi), tanpa tiket/review/QA |
| `/noskill:fix <deskripsi>` | Bug fix atau perubahan kecil lewat mode cepat |
| `/noskill:board` | Tampilkan board tiket, pertanyaan tiket HOLD, dan durasi tiap tahap per tiket |
| `/noskill:lanjut [jawaban]` | Lanjutkan tiket yang tertunda dari sesi sebelumnya |
| `/noskill:feature-flow` | Alur lengkap (mode cepat atau dari PRD) |
| `/noskill:project-profile` | Buat/refresh profil project |

## Alur pemakaian

Panggil `/noskill:feature-flow` lalu jelaskan pekerjaannya.

- **Mode cepat** — bug fix atau fitur kecil. Orkestrator langsung menulis satu tiket (AC positif & negatif, File/Lokasi, Cara Verifikasi), kamu setujui, lalu masuk loop developer → reviewer → QA.
- **Mode lengkap** — fitur atau modul baru, mulai dari PRD. Level BRD bisa dipilih: **lengkap** (BR→UAT, untuk sign-off/UAT formal), **ringkas** (US→AC→TECH + Test Case), atau **tanpa BRD** (tiket langsung dari PRD, AC ditulis di tiket).

Aturan tiket: **satu tiket per endpoint (BE), per fitur/halaman (FE), atau per bug**. Migration, test, dan Swagger ikut ke tiket endpoint-nya, tidak dipecah per layer. Kalau BE dan FE sama-sama berubah, tiket BE memuat **Kontrak API** (path, request, response, kode error) sejak dibuat; tiket FE memakai `integrates_with` ke tiket BE itu sehingga keduanya bisa dikerjakan bersamaan, lalu QA menguji FE dan BE bersama setelah tiket BE DONE. Selama loop, test hanya dijalankan untuk yang tersentuh tiket; typecheck, lint, dan suite penuh sekali di akhir.

Kedua mode bekerja di branch baru (`feat/…` atau `fix/…`), commit per tiket. Di akhir kamu memilih: push + PR (deskripsi PR disusun otomatis dari tiket), merge lokal, atau biarkan dulu.

**Mode paralel** (opsional): selagi tiket A di-review/QA, developer sudah mengerjakan tiket B di git worktree terpisah. Maksimal 2 tiket aktif, atau 3 kalau tiketnya di repo berbeda.

**Hemat waktu per tiket:** revisi dilanjutkan oleh developer yang sama (tidak membaca ulang dari nol); tiket `complexity: simple` dikerjakan developer dengan Sonnet; environment (DB + server) dinyalakan sekali per sesi untuk semua QA; typecheck dan lint memakai versi cepat dengan cache (`tsc --incremental`, `eslint --cache`); laporan lengkap agent disimpan di `docs/noskill/reports/` sehingga sesi utama hanya menerima verdict singkat; Riwayat tiket mencatat jam, dan `/noskill:board` menampilkan durasi developer/review/QA per tiket.

**Multi-repo:** satu fitur bisa menyentuh beberapa repo (misal api NestJS + web Vue + mobile Flutter). Daftarkan repo di bagian `## Repo` pada `project-profile.md`; PRD, BRD, dan tiket tetap di satu repo (repo tempat sesi berjalan). Setiap tiket punya field `repo:`, branch kerja bernama sama dibuat di tiap repo, commit di repo masing-masing, dan di akhir dibuat satu PR per repo yang saling menautkan.

Opsional: isi `tracker: github` atau `tracker: notion` di `docs/noskill/project-profile.md` supaya board tiket tercermin di GitHub Issues atau database Notion. `standup-update` membaca Riwayat tiket langsung. Agent dokumen (`brd-tracer`, `task-planner`) memakai Sonnet, begitu juga `ticket-reviewer` dan `qa-tester`; `developer` memakai model sesi. Test dan quality gate hanya dijalankan untuk file yang tersentuh (developer sekali, QA sekali); suite penuh sekali di akhir.

Mode lengkap:

```
[sesi utama, interaktif]           [agent]
erp-requirements A → prd-writer ──► brd-tracer ──► task-planner ──► tiket TODO
   (tanya-jawab + persetujuan)      docs/noskill/01..05     docs/noskill/tickets/

Per tiket:
TODO ─► IN_PROGRESS ─► REVIEW ─► QA ─► DONE (commit lokal)
        (developer)   (reviewer)  (qa-tester)
             ▲           │          │
             └─ revisi ──┘          └─► BUG ─► developer (debug-assistant)
Blocker / 3x gagal ─► HOLD ─► ditanyakan ke user
```

Agent tidak berbicara langsung satu sama lain. Mereka terhubung lewat file di `docs/noskill/`, dan hanya `feature-flow` yang memindahkan status tiket. Hasil setiap tahap jadi bisa direview, diedit, dan di-commit ke repo project.

Skill lain tetap bisa dipakai sendiri-sendiri. `freelance-proposal` dan `mockup-prototype` dipakai di luar siklus inti. Setelah semua DONE, `user-guide` dan `standup-update` bisa dipakai untuk dokumentasi dan laporan.

## Eval

`evals/` berisi 9 case yang menguji perilaku inti: developer memakai helper yang ada dan menulis test negatif/batas, reviewer menolak duplikasi, mode cepat menulis tiket lalu berhenti di gate, aturan inti dari hook berlaku tanpa skill, task-planner membuat tiket langsung dari PRD (tanpa BRD), task-planner memecah fitur lintas repo jadi tiket per repo, developer bekerja di worktree tiket tanpa menyentuh checkout utama (mode paralel), `/noskill:lazy` memakai helper yang ada tanpa membuat tiket atau abstraksi baru, dan `/noskill:rapikan` mengusulkan penggabungan tiket per layer tanpa mengubah file sebelum disetujui. Jalankan setelah mengubah skill atau agent:

```bash
claude plugin eval . --scaffold --trust-plugin --allow-tools Write Edit Bash
```

Butuh `bubblewrap` dan `socat` di Linux (sandbox untuk Bash). Biaya satu putaran (1 run per case, dengan dan tanpa plugin) sekitar $1–2 (9 case).

## Cara install

### Claude Code (terminal, desktop, VS Code)
```
/plugin install noskill --marketplace awahids/noskill
```
Untuk Claude Code versi lama (sebelum 2.1.275), dua langkah:
```
/plugin marketplace add awahids/noskill
/plugin install noskill@noskill
```
Skill dipanggil dengan prefix plugin, misal `/noskill:fix`. Plugin yang dipasang dengan cara ini hanya ada di komputer itu.

### Akun Claude (claude.ai, aplikasi desktop, Cowork, dan sesi cloud)
Pasang sekali di akun, lalu plugin tersinkron ke chat, Cowork, dan setiap sesi Claude Code yang login dengan akun yang sama:
1. Buka [claude.ai/customize/plugins](https://claude.ai/customize/plugins) (**Customize → Plugins**).
2. Pilih **Add → Add marketplace**, isi `awahids/noskill`.
3. Pilih plugin **noskill**, lalu **Add**. Opsional: aktifkan **Sync automatically** supaya update dari GitHub langsung masuk.
4. Di sesi Claude Code yang sudah terbuka, jalankan `/reload-plugins`.

Di chat claude.ai hanya skill yang aktif; agent dan hook berjalan di Claude Code dan Cowork. Pada plan Team/Enterprise, menu **Add marketplace** bisa dibatasi oleh Owner organisasi.

### Skill satuan di Claude.ai
ZIP satu folder skill utuh (nama folder harus sama dengan `name` di SKILL.md, `references/` ikut di dalamnya), lalu upload lewat **Customize → Skills → + → Upload a skill**. Contoh:
```bash
cd skills && zip -r prd-writer.zip prd-writer
```

## Perubahan

Lihat [CHANGELOG.md](CHANGELOG.md).

## Lisensi

[MIT](LICENSE).
