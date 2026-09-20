# noskill

Koleksi Claude Skills & Agent untuk kerja development sehari-hari Wahid (Rasa Group + freelance) — seluruh isi plugin `wahid-toolkit`, ditambah dua skill dan satu agent untuk kerja ERP/WMS.

## Skills

| Skill | Fungsi |
|---|---|
| [`prd-writer`](prd-writer/) | Menyusun Product Requirements Document lengkap dengan diagram Mermaid |
| [`task-breakdown`](task-breakdown/) | Memecah PRD jadi task development actionable, termasuk task integrasi ke sistem existing |
| [`coding-standards`](coding-standards/) | Naming convention, struktur folder, dan konvensi kode untuk NestJS/Laravel/Golang/Vue/Next.js |
| [`api-doc-standard`](api-doc-standard/) | Standar dokumentasi Swagger/OpenAPI untuk NestJS/Laravel/Golang |
| [`debug-assistant`](debug-assistant/) | Alur debugging terstruktur (reproduce → isolasi → diagnosa → fix & verifikasi) |
| [`mockup-prototype`](mockup-prototype/) | Membuat mockup/prototype UI dari PRD |
| [`user-guide`](user-guide/) | Menyusun dokumentasi end-user yang mudah dipahami orang non-teknis |
| [`standup-update`](standup-update/) | Merangkum aktivitas kerja jadi update standup/status report |
| [`freelance-proposal`](freelance-proposal/) | Template proposal/scoping project freelance dengan harga IDR |
| [`erp-domain-design`](erp-domain-design/) | Checklist desain domain ERP/WMS sebelum bikin schema — stock ledger, RBAC, audit trail, roadmap MVP |
| [`erp-brd-traceability`](erp-brd-traceability/) | Framework requirement ERP dengan traceability: Business Requirement → Process → User Story → Acceptance Criteria → Technical Task → Test Case → UAT |

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

**Claude Code / Claude Cowork (sebagai plugin):**
Copy folder skill yang diinginkan ke `skills/<nama-skill>/` di root plugin kamu, dan file agent ke `agents/`. Detail per-skill ada di README masing-masing folder.

**Claude.ai:**
Upload `SKILL.md` (dan folder `references/` jika ada) lewat pengaturan Skills di akun kamu.

## Lisensi

Bebas dipakai dan dimodifikasi.

