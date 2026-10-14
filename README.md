# noskill

Koleksi Claude Skills & Agent untuk kerja development sehari-hari Wahid (Rasa Group + freelance) — dipaketkan sebagai plugin `noskill`, termasuk skill dan agent untuk kerja ERP/WMS.

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

## Agent

| Agent | Fungsi |
|---|---|
| [`agents/erp-feature-builder.md`](agents/erp-feature-builder.md) | Orkestrator yang menjalankan `erp-domain-design` → `prd-writer` → `erp-brd-traceability` → `task-breakdown` → (`coding-standards`/`api-doc-standard`/`debug-assistant`/`user-guide` sesuai kebutuhan) secara berurutan untuk satu fitur ERP dari ide sampai task siap kerja |

## Alur pemakaian (siklus fitur lengkap)

```
erp-domain-design → prd-writer → erp-brd-traceability → task-breakdown
                                → coding-standards / api-doc-standard (saat implementasi)
                                → debug-assistant (kalau ada bug)
                                → user-guide (dokumentasi akhir)
                                → standup-update (reporting progress)
```
`freelance-proposal` dan `mockup-prototype` dipakai di luar siklus inti — masing-masing untuk scoping client baru dan tahap visual setelah PRD.

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

