# erp-brd-traceability

Framework dokumentasi requirement untuk fitur ERP/WMS/enterprise dengan traceability penuh dari kebutuhan bisnis sampai UAT.

## Rantai 5 layer

```
Business Requirement (BR) → Business Process (PROC) → User Story (US)
      → Acceptance Criteria (AC) → Technical Task (TECH) → Test Case (TC) → UAT
```

## Isinya

- Skema penomoran ID per layer (`BR-INV-001`, `PROC-INV-001`, `US-INV-001`, `AC-001`, `TECH-001`, `TC-INV-001`, `UAT-INV-001`)
- Template tiap layer: struktur BRD, format Business Process, User Story, Acceptance Criteria (Given/When/Then), Technical Task, Test Case, UAT
- Matrix ownership per layer (siapa bikin, siapa approve)
- Struktur folder dokumentasi (`docs/01-business` s.d. `docs/05-testing`)
- Mapping ke Jira/Linear (Epic → Feature → User Story → Technical Task → Sub-task)
- Contoh end-to-end lengkap (fitur Goods Receipt) di [`references/example-goods-receipt.md`](references/example-goods-receipt.md)

## Kapan dipakai

Bikin BRD, requirement fitur ERP/WMS, user story + acceptance criteria, breakdown requirement jadi technical task dengan ID yang bisa ditelusuri, atau dokumentasi fitur cross-functional (purchasing, inventory, sales, finance, manufacturing) yang butuh audit trail requirement → code → test.

## Install

Copy folder ini (termasuk `references/`) ke `skills/erp-brd-traceability/` di plugin atau proyek Claude kamu.

## Terkait

- `erp-domain-design` — dipakai sebelum skill ini, untuk desain modul/ERD
- `agents/erp-feature-builder.md` — menjalankan skill ini sebagai bagian dari pipeline penuh
