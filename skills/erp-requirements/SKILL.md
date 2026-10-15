---
name: erp-requirements
description: >-
  Requirement ERP/WMS dalam dua bagian. (A) Checklist desain domain sebelum menulis schema: master data terpusat, stock ledger (bukan field stock), workflow status, RBAC, audit trail, document numbering, roadmap MVP, modular monolith. (B) Dokumen requirement dengan rantai ID traceable BR → PROC → US → AC → TECH → TC → UAT dan matrix ownership. Gunakan saat mendesain modul/ERD ERP (inventory, purchasing, sales, finance, WMS), atau saat user minta BRD, user story + acceptance criteria, traceability matrix, atau requirement formal fitur ERP.
---

# ERP Requirements

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.

Dua bagian yang dipakai berurutan:
- **Bagian A — Desain domain:** checklist sebelum menulis schema/ERD. Dipakai di `feature-flow` Tahap 1, di sesi utama.
- **Bagian B — BRD traceability:** dokumen requirement formal dengan ID yang bisa ditelusuri. Dipakai di `feature-flow` Tahap 3 oleh agent `brd-tracer`.

Kalau permintaannya hanya salah satu (misal "desain ERD inventory" atau "buatkan user story + AC"), pakai bagian itu saja.

## Bagian A — Desain Domain

Kumpulan prinsip desain untuk sistem ERP/WMS supaya konsisten di semua modul dan tidak menimbulkan masalah data ("kok stock di Sales 100, Warehouse 87, Dashboard 92?"). Pakai sebagai checklist sebelum membuat ERD/schema/API untuk modul baru.

### 0. Tentukan core business dulu

Sebelum bikin modul apapun, jawab: "perusahaan ini menghasilkan uang dari proses apa?" Gambar alur besarnya dulu (mis. Purchasing → Receiving → Warehouse → Production → Sales Order → Delivery → Invoice → Payment). Modul ERP yang dibutuhkan mengikuti alur ini, bukan sebaliknya.

### 1. Master Data adalah fondasi — satu sumber, dipakai semua modul

Jangan biarkan tiap modul punya tabel item/customer sendiri. Struktur minimal:
```
Organization → Company → Branch → Department → Warehouse
Product      → Item → Category / Unit / Brand / Variant / Batch-Lot / Serial Number
Business Partner → Customer / Vendor / Employee
```
Satu master `Item` dipakai Purchasing, Inventory, Sales, Production, Finance — bukan masing-masing modul punya copy sendiri.

### 2. Stock Ledger, bukan field stock

**Jangan** simpan `item.stock = 100` langsung. **Pakai** stock movement / ledger sebagai sumber audit:
```
StockMovement: id, item, warehouse, location, batch, type, reference, quantity, direction, created_at
```
Contoh entry: `PURCHASE_RECEIVE +100`, `SALES_SHIP -20`, `TRANSFER_OUT -10`, `TRANSFER_IN +10`, `ADJUSTMENT +5`.
`current_stock = SUM(semua stock movement)` — atau pakai `stock_balances` sebagai cache untuk performa, tapi ledger tetap jadi sumber kebenaran saat ada pertanyaan "kenapa stock item A tinggal 70?".

### 3. Semua transaksi punya workflow status, bukan sekadar CRUD

Contoh Purchase Order: `DRAFT → SUBMITTED → APPROVED → PARTIALLY_RECEIVED → COMPLETED`.
Contoh Sales Order: `DRAFT → SUBMITTED → APPROVED → PICKING → PACKING → SHIPPED → COMPLETED`.
Setiap dokumen transaksi idealnya punya: Header, Details, Status, Approval, History, Audit Log.

### 4. RBAC, bukan hardcode role

```
User → Role → Permission
```
Hindari `if (user.role === 'ADMIN') ...` tersebar di code. Definisikan permission granular per aksi (mis. `inventory.goods_receipt.confirm`, `purchasing.po.approve`).

### 5. Audit Trail wajib untuk sistem serius

Simpan minimal: Who, What, When, Before, After, Reason. Contoh:
```
User: budi.santoso | Action: UPDATE | Module: Purchase Order | Document: PO/260920/0012
Before: quantity=100 → After: quantity=120 | Reason: Vendor confirmation
```

### 6. Document numbering tersentralisasi

Jangan generate nomor dokumen (PO/SO/GR/DO/INV) di frontend. Buat `document_sequence` service terpusat. Format umum: `PO/2609/00001`.

### 7. Tentukan source of truth per entity — hindari data ganda

```
Item        → Item Master     → dipakai Purchasing, Inventory, Sales, Production, Finance
Customer    → Customer Master → dipakai Sales, Delivery, Invoice, Payment
Stock       → Stock Ledger    → dipakai Warehouse, Sales, Purchasing, Production, Reporting
```
Jangan sampai Sales, Warehouse, dan Production masing-masing punya angka stock sendiri yang bisa beda-beda.

### 8. Urutan desain: business flow dulu, baru ERD

```
Business Process → Requirement → Workflow → Document → Database Model → API → UI
```
Jangan langsung "buat Prisma schema → buat CRUD → buat frontend" tanpa memetakan proses bisnis dan workflow dulu.

### 9. Roadmap MVP bertahap — jangan bangun 15 modul sekaligus

| Fase | Modul |
|---|---|
| 1 — Foundation | Auth, User, Role, Permission, Company, Branch, Warehouse, Audit Log, Document Number |
| 2 — Master | Item, Category, Unit, Customer, Vendor, Warehouse, Location |
| 3 — Inventory | Opening Stock, Stock Receive/Issue/Transfer/Adjustment, Stock Ledger, Stock Balance, Batch/Lot |
| 4 — Purchasing | Purchase Request, Purchase Order, Goods Receipt, Supplier Invoice |
| 5 — Sales | Sales Order, Picking, Delivery Order, Sales Invoice |
| 6 — Finance | Account, Journal, Invoice, Payment, AR, AP |
| Setelahnya | Manufacturing, HR, Payroll, Asset, CRM, Project, Maintenance, BI |

### 10. Arsitektur: modular monolith dulu, microservices belakangan

Mulai dari satu aplikasi (mis. NestJS) dengan modul terpisah jelas:
```
apps/erp-api/src/modules/
  ├── iam/  ├── master-data/  ├── purchasing/  ├── inventory/
  ├── sales/  ├── finance/  ├── manufacturing/  └── audit/
```
Satu PostgreSQL sebagai starting point. Microservices baru relevan kalau sudah butuh independent deployment/scaling, team ownership per service, failure isolation, domain sudah matang, dan integration boundary jelas — bukan karena "biar modern". Kalau boundary bisnis belum jelas, microservices cuma menambah kompleksitas (network, API gateway, message broker, distributed transaction, deployment, monitoring, retry, event consistency, service discovery) padahal bisnisnya sendiri belum stabil.

Ikuti urutan: `Business Capability → Bounded Context → Application Module → Technical Component`. Contoh: Warehouse Management → Inventory Context → Inventory Module → `StockService`, `StockMovementService`, `ReservationService`, `StockRepository`.

### 11. Inventory harus jadi single owner stock, bukan diubah langsung modul lain

Salah: `Sales → UPDATE stock` langsung, `Purchasing → UPDATE stock` langsung.
Benar: `Purchasing → Goods Receipt → Inventory → Stock Movement → Stock Balance` dan `Sales → Shipment → Inventory → Stock Movement → Stock Balance`.

### 12. Event untuk side-effect, bukan untuk transaksi inti

Event cocok untuk hal seperti notifikasi/integrasi setelah `Goods Receipt Confirmed`. Tapi transaksi inti (mis. confirm GR + update stock) sebaiknya tetap satu transaction boundary yang jelas — jangan pecah jadi rantai Service A → Event → Service B → Event → Service C kalau sebenarnya bisa selesai dalam satu transaction.


## Bagian B — BRD Traceability

Framework 5-layer untuk mendokumentasikan fitur ERP/enterprise dari masalah bisnis sampai rilis, dengan setiap artefak bisa ditelusuri (traceable) ke artefak sebelum dan sesudahnya. Dipakai supaya tidak ada fitur yang "requirement-nya nggak jelas dari mana" dan tidak ada bug yang "nggak ketahuan melanggar requirement yang mana".

### Kapan pakai full chain vs ringkas

- **Fitur baru / cross-functional / butuh sign-off bisnis** (mis. Goods Receipt, approval PO, perhitungan stock) → jalankan full chain (Layer 1–5).
- **Perubahan kecil / bugfix / internal tooling** → cukup User Story + Acceptance Criteria + Technical Task (Layer 3–4), skip BRD & UAT formal.
- Kalau tidak yakin, tanya user: "ini perlu full BRD-to-UAT, atau langsung ke user story + AC saja?"

### Alur 5 Layer

```
1. BUSINESS REQUIREMENT (BR)      "Kenapa & apa yang bisnis butuhkan?"
        ↓
2. BUSINESS PROCESS (PROC)        "Bagaimana proses bisnis berjalan?"
        ↓
3. FUNCTIONAL SPEC (US + FR + AC) "Sistem harus berperilaku seperti apa?"
        ↓
4. TECHNICAL SPEC (TECH)          "Bagaimana sistem dibangun?"
        ↓
5. TESTING / UAT (TC + UAT)       "Buktikan sistem sesuai requirement"
```

Prinsip utama: **pisahkan kebutuhan bisnis, perilaku sistem, dan cara implementasi.** Jangan langsung "user minta menu GR" → "oke bikin CRUD Goods Receipt". Selalu urut: masalah bisnis → proses bisnis → business rule → requirement → acceptance criteria → baru desain teknis → coding.

### Skema penomoran ID

Pakai prefix + domain + nomor urut, konsisten di semua layer supaya bisa di-grep dan di-trace:

| Layer | Prefix | Contoh |
|---|---|---|
| Business Requirement | `BR-<DOMAIN>-NNN` | `BR-INV-001` |
| Business Process | `PROC-<DOMAIN>-NNN` | `PROC-INV-001` |
| User Story | `US-<DOMAIN>-NNN` | `US-INV-001` |
| Functional Requirement | `FR-<DOMAIN>-NNN` | `FR-INV-001` |
| Acceptance Criteria | `AC-NNN` (di bawah satu US) | `AC-001`..`AC-005` |
| Technical Task | `TECH-NNN` (di bawah satu US) | `TECH-001`..`TECH-010` |
| Test Case | `TC-<DOMAIN>-NNN` | `TC-INV-001` |
| UAT Scenario | `UAT-<DOMAIN>-NNN` | `UAT-INV-001` |

`<DOMAIN>` singkat 3 huruf sesuai modul: `INV` (inventory), `PUR` (purchasing), `SLS` (sales), `FIN` (finance), `MFG` (manufacturing).

Rantai lengkap satu fitur:
```
BR-INV-001 → PROC-INV-001 → US-INV-001 → [AC-001..AC-00N] → [TECH-001..TECH-00N] → [TC-001..TC-00N] → UAT-INV-001 → Release
```

### Layer 1 — Business Requirement (BR)

Jawab "kenapa sistem ini dibuat", bukan database/API/UI. Isi minimal:

1. Document Information
2. Background
3. Business Problem
4. Business Objective
5. Scope / Out of Scope
6. Stakeholders
7. Business Requirements
8. Business Rules
9. Success Metrics
10. Assumptions & Constraints
11. Glossary

Contoh singkat:
```
BR-INV-001
Business Requirement: Perusahaan membutuhkan proses penerimaan barang
yang dapat mencatat barang berdasarkan Purchase Order dan memperbarui
stock secara terkontrol.
```

### Layer 2 — Business Process (PROC)

Jelaskan alur nyata proses bisnisnya (bukan implementasi). Field yang perlu diisi: Process ID, Objective, Trigger, Actor, Precondition, Main Flow, Alternative Flow, Exception Flow, Business Rules, Output, Status/Approval, Integration.

Contoh business rule yang biasa muncul di sini:
- "PO harus APPROVED sebelum dapat dibuatkan GR."
- "Received Qty tidak boleh melebihi Outstanding Qty."
- "GR yang sudah CONFIRMED tidak boleh diedit."

Ini juga tempat menentukan status/workflow transaksi, lihat Bagian A untuk pola workflow status yang konsisten.

### Layer 3 — Functional Specification (US + FR + AC)

Jembatan business ↔ engineering. Isi: User Story, Functional Requirement, Acceptance Criteria, validasi, permission, status transition, notification, audit requirement, UI requirement, error handling.

**User Story** — format standar:
```
US-INV-001
Sebagai <role>,
saya ingin <aksi>,
agar <manfaat/tujuan bisnis>.
```

**Acceptance Criteria** — format Given/When/Then, satu AC = satu kondisi terverifikasi:
```
AC-001
Given PO sudah APPROVED
When Warehouse membuat GR
Then sistem menampilkan item dan outstanding quantity.

AC-002
Given outstanding quantity = 30
When user memasukkan quantity = 40
Then sistem menolak transaksi.
```
AC menjadi **kontrak perilaku sistem** — jangan mulai desain teknis sebelum AC lengkap mencakup: happy path, validation/reject path, side-effect (mis. stock movement tercipta), dan larangan (mis. data yang sudah confirmed tidak boleh diedit).

### Layer 4 — Technical Specification (TECH)

Baru di sini bicara arsitektur, ERD, API, service, transaction, authorization, event, logging. Turunkan Technical Task langsung dari AC yang sudah dibuat — jangan sebaliknya.

```
US-INV-001 + AC-001..AC-005
        ↓
TECH-001  Buat model database GoodsReceipt & item-nya
TECH-002  Implementasi POST /goods-receipts
TECH-003  Validasi outstanding quantity
TECH-004  Implementasi transaksi confirm GR
TECH-005  Buat Stock Movement saat GR confirmed
TECH-006  Update PO received quantity
TECH-007  Frontend form + detail GR
TECH-008  Tambah permission inventory.goods_receipt.confirm
TECH-009  Implementasi audit log
```

Technical Task **bukan** requirement bisnis — dia hasil turunan dari functional requirement/AC. Untuk breakdown task lebih detail dengan struktur folder/konvensi kode proyek, lanjutkan ke skill `task-breakdown` / `coding-standards` — `task-breakdown` memetakan tiap TECH-xxx ke Task-ID lewat kolom **Trace**, jadi rantai traceability tetap utuh sampai task tracker.

### Layer 5 — Testing & UAT

Setiap AC harus punya minimal satu Test Case **positif** dan, kalau AC punya kondisi tolak/larangan, minimal satu Test Case **negatif**. Tandai jenisnya di field `Type`:
```
TC-INV-001
Requirement : US-INV-001 / AC-002
Type        : Negatif
Scenario    : GR quantity melebihi outstanding
Input       : Outstanding = 30, Received = 40
Expected    : Sistem menolak transaksi.
```

UAT dilakukan business user, langkahnya urutan aksi nyata:
```
UAT-INV-001
Warehouse Staff → pilih PO → input receiving → confirm
→ cek stock → cek GR → cek stock movement → approve sesuai proses bisnis.
```

### Ownership per layer

| Layer | Main Owner | Input dari | Approver |
|---|---|---|---|
| BRD | BA / Product Owner | Business Owner + SME | Business Owner |
| Process | BA | Process Owner + SME | Process Owner |
| Functional | BA / System Analyst | SME + Tech Lead | PO / Business Owner |
| Technical | Architect / Tech Lead | Developer + BA | Architect / Tech Lead |
| Testing | QA | BA + Dev + SME | Business User |

Hindari tiap divisi bikin BRD sendiri-sendiri untuk proses cross-functional (purchasing → warehouse → finance) — pakai centralized ownership di atas + input lintas fungsi.

### Struktur folder dokumentasi (kalau disimpan di repo)

```
<docs>/
├── 01-business/        (BRD.md, business-objectives.md, scope.md, stakeholders.md, glossary.md)
├── 02-process/         (per modul: purchasing/, inventory/, sales/, finance/)
├── 03-functional/      (per modul, isi user story + FR + AC)
├── 04-technical/       (architecture.md, module-boundaries.md, database.md, api.md, security.md, adr/)
└── 05-testing/         (test-cases/, integration/, uat/)
```

### Mapping ke Jira/Linear

```
Epic (mis. "Inventory Management")
  └── Feature (mis. "Goods Receipt")
        └── User Story (US-INV-001)
              ├── Technical Task (TECH-001..TECH-00N)
              └── QA Sub-task (TC-001..TC-00N)
```
Task management (Jira/Linear) mengelola pekerjaan; dokumen requirement tetap jadi sumber kebenaran untuk why/what/how/expected behavior — jangan gunakan tiket sebagai pengganti dokumen.


## Cara pakai

**Desain domain (Bagian A):**
1. Kalau user mau desain modul/ERD baru untuk ERP/WMS, jalankan checklist Bagian A satu per satu sebelum menulis schema.
2. Kalau user tanya "modul apa duluan", rujuk roadmap MVP (A.9).
3. Konvensi penamaan/struktur folder kode ada di skill `coding-standards`.

**Dokumen requirement (Bagian B):**
Kalau user minta dibuatkan requirement/BRD/user-story untuk fitur ERP:
1. Tanyakan domain modulnya (inventory/purchasing/sales/finance/manufacturing) untuk prefix ID.
2. Tanyakan level: full chain (BR→UAT) atau ringkas (US→AC→TECH saja).
3. Gali Business Problem & business rule dulu sebelum masuk ke User Story — jangan loncat.
4. Tulis output mengikuti template tiap layer di atas, dengan ID yang konsisten dan saling merujuk.
5. Kalau butuh contoh end-to-end lengkap satu fitur (Goods Receipt), baca `references/example-goods-receipt.md`.

## Posisi dalam alur noskill

```
Bagian A (desain domain) → prd-writer → Bagian B (BRD) → task-breakdown → coding-standards → debug-assistant → user-guide
```
Untuk menjalankan seluruh alur sampai tiket DONE (develop → review → QA), gunakan skill `feature-flow` — Bagian B dikerjakan agent `brd-tracer` yang memuat skill ini.
