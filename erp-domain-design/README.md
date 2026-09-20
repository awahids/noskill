# erp-domain-design

Checklist & prinsip desain domain untuk sistem ERP/WMS/inventory/purchasing/sales/finance — dipakai **sebelum** menulis database schema atau CRUD.

## Isinya

- Menentukan core business flow sebelum memilih modul
- Master data terpusat (satu sumber, dipakai semua modul)
- Stock ledger / stock movement (bukan field `stock` langsung)
- Status workflow per transaksi (draft → submitted → approved → ...)
- RBAC (User → Role → Permission), bukan hardcode role
- Audit trail (who, what, when, before, after, reason)
- Document numbering tersentralisasi
- Source-of-truth per entity (item, customer, stock)
- Urutan desain: business flow → requirement → workflow → document → database model → API → UI
- Roadmap MVP bertahap (Foundation → Master → Inventory → Purchasing → Sales → Finance)
- Modular monolith dengan bounded context, sebelum microservices

## Kapan dipakai

Setiap kali mendesain modul baru untuk ERP/WMS, membuat ERD/database schema untuk sistem transaksional, menentukan arsitektur ERP dari nol, atau menyusun blueprint dengan stack NestJS/Prisma/PostgreSQL.

## Install

Copy folder ini ke `skills/erp-domain-design/` di plugin atau proyek Claude kamu (butuh `SKILL.md` di dalamnya untuk terbaca sebagai skill).

## Terkait

- `erp-brd-traceability` — lanjutan skill ini untuk dokumentasi requirement formal
- `agents/erp-feature-builder.md` — menjalankan skill ini sebagai bagian dari pipeline penuh
