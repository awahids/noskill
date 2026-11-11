# erp-requirements

BRD traceability untuk fitur ERP/enterprise: rantai ID BR → PROC → US (+FR) → AC → TECH → TC → UAT, level lengkap atau ringkas, ownership per layer, struktur folder `01-business` … `05-testing`, dan pemetaan ke Jira/Linear. Contoh lengkap Goods Receipt ada di `references/example-goods-receipt.md`.

Checklist desain domain (dulu Bagian A) sekarang skill terpisah: [`erp-domain-design`](../erp-domain-design/).

## Kapan dipakai

Saat diminta BRD, user story + acceptance criteria, atau traceability matrix. Di `feature-flow` full mode dikerjakan agent `brd-tracer`.

## Terkait

- `erp-domain-design` — desain domain sebelum PRD
- `prd-writer` — PRD ditulis sebelum BRD
- `task-breakdown` — AC dan TECH dari BRD jadi tiket
- `coding-standards` — konvensi kode saat implementasi
