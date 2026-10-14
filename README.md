# noskill

Koleksi Claude Skills & Agent untuk kerja development sehari-hari — dipaketkan sebagai plugin `noskill`, termasuk alur tiket lengkap (develop → review → QA) dengan agent.

## Skills

| Skill | Fungsi |
|---|---|
| [`prd-writer`](skills/prd-writer/) | Menyusun Product Requirements Document lengkap dengan diagram Mermaid |
| [`task-breakdown`](skills/task-breakdown/) | Memecah PRD jadi task development actionable, termasuk task integrasi ke sistem existing |
| [`coding-standards`](skills/coding-standards/) | Naming convention, struktur folder, dan konvensi kode untuk NestJS/Laravel/Golang/Vue/Next.js |
| [`api-doc-standard`](skills/api-doc-standard/) | Standar dokumentasi Swagger/OpenAPI untuk NestJS/Laravel/Golang |
| [`debug-assistant`](skills/debug-assistant/) | Alur debugging terstruktur (reproduce → isolasi → diagnosa → fix & verifikasi) |
| [`mockup-prototype`](skills/mockup-prototype/) | Membuat mockup/prototype UI dari PRD |
| [`user-guide`](skills/user-guide/) | Menyusun dokumentasi end-user yang mudah dipahami orang non-teknis |
| [`standup-update`](skills/standup-update/) | Merangkum aktivitas kerja jadi update standup/status report |
| [`freelance-proposal`](skills/freelance-proposal/) | Template proposal/scoping project freelance dengan harga IDR |
| [`erp-domain-design`](skills/erp-domain-design/) | Checklist desain domain ERP/WMS sebelum bikin schema — stock ledger, RBAC, audit trail, roadmap MVP |
| [`erp-brd-traceability`](skills/erp-brd-traceability/) | Framework requirement ERP dengan traceability: Business Requirement → Process → User Story → Acceptance Criteria → Technical Task → Test Case → UAT |
| [`feature-flow`](skills/feature-flow/) | Orkestrator siklus fitur penuh: PRD → BRD → tiket → develop → review → QA → DONE (atau BUG/HOLD) |
| [`ticket-workflow`](skills/ticket-workflow/) | Format file tiket dan alur status (TODO → IN_PROGRESS → REVIEW → QA → DONE, plus BUG & HOLD) |

## Agent

Dipanggil oleh `feature-flow`. Tiap agent memuat skill yang relevan lewat field `skills:`.

| Agent | Peran | Skill yang dimuat | Bisa ubah kode? |
|---|---|---|---|
| [`brd-tracer`](agents/brd-tracer.md) | PRD → BR/PROC/US/AC/TECH/TC di `docs/01..05` | `erp-brd-traceability`, `erp-domain-design` | Tidak (hanya tulis dokumen) |
| [`task-planner`](agents/task-planner.md) | BRD → file tiket `docs/tickets/*.md` status TODO | `task-breakdown`, `ticket-workflow` | Tidak (hanya tulis tiket) |
| [`developer`](agents/developer.md) | Kerjakan satu tiket / fix BUG sampai Cara Verifikasi lolos | `coding-standards`, `debug-assistant`, `ticket-workflow` | Ya |
| [`ticket-reviewer`](agents/ticket-reviewer.md) | Cek perubahan sesuai AC tiket & standar → APPROVED / CHANGES_REQUESTED / BLOCKED | `coding-standards`, `ticket-workflow` | Tidak |
| [`qa-tester`](agents/qa-tester.md) | Jalankan test terhadap AC & TC → PASS / FAIL (bug report) / BLOCKED | `ticket-workflow` | Tidak |

## Aturan inti yang selalu aktif

Plugin ini memasang hook `SessionStart` ([`hooks/core-rules.md`](hooks/core-rules.md)) yang memuat ±10 baris aturan kerja ke setiap sesi, juga saat tidak ada skill yang dipanggil: ubah hanya yang diminta, pikir dulu, solusi paling sederhana, reuse helper yang ada, test positif/negatif/batas dengan bukti RED, klaim selesai hanya dengan bukti. Detail lengkapnya tetap ada di `coding-standards`.

## Alur pemakaian

Panggil `/noskill:feature-flow` lalu jelaskan pekerjaannya.

- **Mode cepat** — bug fix atau fitur kecil. Orkestrator langsung menulis satu tiket (AC positif & negatif, File/Lokasi, Cara Verifikasi), kamu setujui, lalu masuk loop developer → reviewer → QA.
- **Mode lengkap** — fitur atau modul baru, mulai dari PRD.

Kedua mode bekerja di branch baru (`feat/…` atau `fix/…`), commit per tiket. Di akhir kamu memilih: push + PR, merge lokal, atau biarkan dulu.

Mode lengkap:

```
[sesi utama, interaktif]           [agent]
erp-domain-design → prd-writer ──► brd-tracer ──► task-planner ──► tiket TODO
   (tanya-jawab + persetujuan)      docs/01..05     docs/tickets/

Per tiket:
TODO ─► IN_PROGRESS ─► REVIEW ─► QA ─► DONE (commit lokal)
        (developer)   (reviewer)  (qa-tester)
             ▲           │          │
             └─ revisi ──┘          └─► BUG ─► developer (debug-assistant)
Blocker / 3x gagal ─► HOLD ─► ditanyakan ke user
```

Agent tidak berbicara langsung satu sama lain. Mereka terhubung lewat file di `docs/`, dan hanya `feature-flow` yang memindahkan status tiket. Hasil setiap tahap jadi bisa direview, diedit, dan di-commit ke repo project.

Skill lain tetap bisa dipakai sendiri-sendiri. `freelance-proposal` dan `mockup-prototype` dipakai di luar siklus inti. Setelah semua DONE, `user-guide` dan `standup-update` bisa dipakai untuk dokumentasi dan laporan.

## Eval

`evals/` berisi 4 case yang menguji perilaku inti: developer memakai helper yang ada dan menulis test negatif/batas, reviewer menolak duplikasi, mode cepat menulis tiket lalu berhenti di gate, dan aturan inti dari hook berlaku tanpa skill. Jalankan setelah mengubah skill atau agent:

```bash
claude plugin eval . --scaffold --trust-plugin --allow-tools Write Edit Bash
```

Butuh `bubblewrap` dan `socat` di Linux (sandbox untuk Bash). Biaya satu putaran (1 run per case, dengan dan tanpa plugin) sekitar $1.

## Cara pakai

**Claude Code (sebagai plugin):**
```
/plugin install noskill --marketplace awahids/noskill
```
Untuk Claude Code versi lama (sebelum 2.1.275), dua langkah:
```
/plugin marketplace add awahids/noskill
/plugin install noskill@noskill
```
Skill dipanggil dengan prefix plugin, misal `/noskill:prd-writer`. Detail per-skill ada di README masing-masing folder di `skills/`.

**Claude.ai:**
ZIP satu folder skill utuh (nama folder harus sama dengan `name` di SKILL.md, `references/` ikut di dalamnya), lalu upload lewat **Customize → Skills → + → Upload a skill**. Contoh:
```bash
cd skills && zip -r prd-writer.zip prd-writer
```

## Lisensi

Bebas dipakai dan dimodifikasi.

