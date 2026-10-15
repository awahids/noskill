# erp-requirements

Requirement ERP/WMS dalam dua bagian yang dipakai berurutan:

- **Bagian A — Desain domain:** checklist sebelum menulis schema/ERD — core business, master data terpusat, stock ledger (bukan field stock), workflow status, RBAC, audit trail, penomoran dokumen, source of truth, roadmap MVP, modular monolith, inventory sebagai pemilik stok, event untuk side-effect.
- **Bagian B — BRD traceability:** rantai ID BR → PROC → US (+FR) → AC → TECH → TC → UAT, level lengkap atau ringkas, ownership per layer, struktur folder `01-business` … `05-testing`, dan pemetaan ke Jira/Linear. Contoh lengkap Goods Receipt ada di `references/example-goods-receipt.md`.

## Kapan dipakai

Saat mendesain modul/ERD ERP atau WMS, atau saat diminta BRD, user story + acceptance criteria, atau traceability matrix. Di `feature-flow`, Bagian A dipakai di Tahap 1 dan Bagian B dikerjakan agent `brd-tracer`.

## Terkait

- `prd-writer` — PRD ditulis di antara Bagian A dan Bagian B
- `task-breakdown` — AC dan TECH dari Bagian B jadi tiket
- `coding-standards` — konvensi kode saat implementasi
