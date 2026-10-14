---
name: erp-domain-design
description: >-
  Checklist desain domain ERP/WMS sebelum menulis schema: master data terpusat, stock ledger (bukan field stock), workflow status, RBAC, audit trail, document numbering, roadmap MVP, modular monolith. Gunakan saat mendesain modul/ERD ERP, inventory, purchasing, sales, atau finance.
---

# ERP Domain Design Checklist

Kumpulan prinsip desain untuk sistem ERP/WMS supaya konsisten di semua modul dan tidak menimbulkan masalah data ("kok stock di Sales 100, Warehouse 87, Dashboard 92?"). Pakai sebagai checklist sebelum membuat ERD/schema/API untuk modul baru.

## 0. Tentukan core business dulu

Sebelum bikin modul apapun, jawab: "perusahaan ini menghasilkan uang dari proses apa?" Gambar alur besarnya dulu (mis. Purchasing → Receiving → Warehouse → Production → Sales Order → Delivery → Invoice → Payment). Modul ERP yang dibutuhkan mengikuti alur ini, bukan sebaliknya.

## 1. Master Data adalah fondasi — satu sumber, dipakai semua modul

Jangan biarkan tiap modul punya tabel item/customer sendiri. Struktur minimal:
```
Organization → Company → Branch → Department → Warehouse
Product      → Item → Category / Unit / Brand / Variant / Batch-Lot / Serial Number
Business Partner → Customer / Vendor / Employee
```
Satu master `Item` dipakai Purchasing, Inventory, Sales, Production, Finance — bukan masing-masing modul punya copy sendiri.

## 2. Stock Ledger, bukan field stock

**Jangan** simpan `item.stock = 100` langsung. **Pakai** stock movement / ledger sebagai sumber audit:
```
StockMovement: id, item, warehouse, location, batch, type, reference, quantity, direction, created_at
```
Contoh entry: `PURCHASE_RECEIVE +100`, `SALES_SHIP -20`, `TRANSFER_OUT -10`, `TRANSFER_IN +10`, `ADJUSTMENT +5`.
`current_stock = SUM(semua stock movement)` — atau pakai `stock_balances` sebagai cache untuk performa, tapi ledger tetap jadi sumber kebenaran saat ada pertanyaan "kenapa stock item A tinggal 70?".

## 3. Semua transaksi punya workflow status, bukan sekadar CRUD

Contoh Purchase Order: `DRAFT → SUBMITTED → APPROVED → PARTIALLY_RECEIVED → COMPLETED`.
Contoh Sales Order: `DRAFT → SUBMITTED → APPROVED → PICKING → PACKING → SHIPPED → COMPLETED`.
Setiap dokumen transaksi idealnya punya: Header, Details, Status, Approval, History, Audit Log.

## 4. RBAC, bukan hardcode role

```
User → Role → Permission
```
Hindari `if (user.role === 'ADMIN') ...` tersebar di code. Definisikan permission granular per aksi (mis. `inventory.goods_receipt.confirm`, `purchasing.po.approve`).

## 5. Audit Trail wajib untuk sistem serius

Simpan minimal: Who, What, When, Before, After, Reason. Contoh:
```
User: Wahid | Action: UPDATE | Module: Purchase Order | Document: PO/260920/0012
Before: quantity=100 → After: quantity=120 | Reason: Vendor confirmation
```

## 6. Document numbering tersentralisasi

Jangan generate nomor dokumen (PO/SO/GR/DO/INV) di frontend. Buat `document_sequence` service terpusat. Format umum: `PO/2609/00001`.

## 7. Tentukan source of truth per entity — hindari data ganda

```
Item        → Item Master     → dipakai Purchasing, Inventory, Sales, Production, Finance
Customer    → Customer Master → dipakai Sales, Delivery, Invoice, Payment
Stock       → Stock Ledger    → dipakai Warehouse, Sales, Purchasing, Production, Reporting
```
Jangan sampai Sales, Warehouse, dan Production masing-masing punya angka stock sendiri yang bisa beda-beda.

## 8. Urutan desain: business flow dulu, baru ERD

```
Business Process → Requirement → Workflow → Document → Database Model → API → UI
```
Jangan langsung "buat Prisma schema → buat CRUD → buat frontend" tanpa memetakan proses bisnis dan workflow dulu.

## 9. Roadmap MVP bertahap — jangan bangun 15 modul sekaligus

| Fase | Modul |
|---|---|
| 1 — Foundation | Auth, User, Role, Permission, Company, Branch, Warehouse, Audit Log, Document Number |
| 2 — Master | Item, Category, Unit, Customer, Vendor, Warehouse, Location |
| 3 — Inventory | Opening Stock, Stock Receive/Issue/Transfer/Adjustment, Stock Ledger, Stock Balance, Batch/Lot |
| 4 — Purchasing | Purchase Request, Purchase Order, Goods Receipt, Supplier Invoice |
| 5 — Sales | Sales Order, Picking, Delivery Order, Sales Invoice |
| 6 — Finance | Account, Journal, Invoice, Payment, AR, AP |
| Setelahnya | Manufacturing, HR, Payroll, Asset, CRM, Project, Maintenance, BI |

## 10. Arsitektur: modular monolith dulu, microservices belakangan

Mulai dari satu aplikasi (mis. NestJS) dengan modul terpisah jelas:
```
apps/erp-api/src/modules/
  ├── iam/  ├── master-data/  ├── purchasing/  ├── inventory/
  ├── sales/  ├── finance/  ├── manufacturing/  └── audit/
```
Satu PostgreSQL sebagai starting point. Microservices baru relevan kalau sudah butuh independent deployment/scaling, team ownership per service, failure isolation, domain sudah matang, dan integration boundary jelas — bukan karena "biar modern". Kalau boundary bisnis belum jelas, microservices cuma menambah kompleksitas (network, API gateway, message broker, distributed transaction, deployment, monitoring, retry, event consistency, service discovery) padahal bisnisnya sendiri belum stabil.

Ikuti urutan: `Business Capability → Bounded Context → Application Module → Technical Component`. Contoh: Warehouse Management → Inventory Context → Inventory Module → `StockService`, `StockMovementService`, `ReservationService`, `StockRepository`.

## 11. Inventory harus jadi single owner stock, bukan diubah langsung modul lain

Salah: `Sales → UPDATE stock` langsung, `Purchasing → UPDATE stock` langsung.
Benar: `Purchasing → Goods Receipt → Inventory → Stock Movement → Stock Balance` dan `Sales → Shipment → Inventory → Stock Movement → Stock Balance`.

## 12. Event untuk side-effect, bukan untuk transaksi inti

Event cocok untuk hal seperti notifikasi/integrasi setelah `Goods Receipt Confirmed`. Tapi transaksi inti (mis. confirm GR + update stock) sebaiknya tetap satu transaction boundary yang jelas — jangan pecah jadi rantai Service A → Event → Service B → Event → Service C kalau sebenarnya bisa selesai dalam satu transaction.

## Cara pakai skill ini

1. Kalau user mau desain modul/ERD baru untuk ERP/WMS, jalankan checklist di atas satu per satu sebelum menulis schema.
2. Kalau user tanya "modul apa duluan", rujuk tabel roadmap MVP di poin 9.
3. Kalau user mau bikin dokumen requirement formal untuk fitur yang didesain di sini, lanjutkan ke skill `erp-brd-traceability`.
4. Kalau user tanya soal konvensi penamaan/struktur folder code spesifik proyeknya, lanjutkan ke skill `coding-standards`.

## Posisi dalam alur noskill

Skill ini jadi langkah paling awal sebelum PRD/requirement ditulis:
```
erp-domain-design (skill ini) → prd-writer → erp-brd-traceability → task-breakdown
                                                                    → coding-standards / api-doc-standard
```
Untuk menjalankan seluruh alur dari desain sampai tiket DONE (develop → review → QA), gunakan skill `feature-flow`.
