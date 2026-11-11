# erp-domain-design

Checklist desain domain ERP/WMS sebelum menulis schema/ERD — core business, master data terpusat, stock ledger (bukan field stock), workflow status, RBAC, audit trail, penomoran dokumen, source of truth, roadmap MVP, modular monolith, inventory sebagai pemilik stok, event untuk side-effect.

## Kapan dipakai

Saat mendesain modul/ERD ERP atau WMS, atau bertanya "modul mana dulu". Di `feature-flow` full mode, agent `product-manager` memuatnya untuk menyusun pertanyaan dan PRD.

## Terkait

- `prd-writer` — PRD ditulis sesudah desain domain
- `erp-requirements` — BRD traceability (BR → UAT) sesudah PRD
