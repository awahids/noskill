---
name: erp-brd-traceability
description: >-
  Framework dokumentasi requirement untuk fitur ERP/WMS/enterprise dengan traceability penuh dari bisnis sampai UAT — BR (Business Requirement) menuju PROC (Business Process) menuju US (User Story) menuju AC (Acceptance Criteria) menuju TECH (Technical Task) menuju TC (Test Case) menuju UAT. Gunakan setiap kali user minta bikin BRD, requirement fitur ERP/WMS, "user story dan acceptance criteria", breakdown requirement jadi technical task dengan ID traceable, traceability matrix, atau dokumentasi fitur cross-functional (purchasing, inventory, sales, finance, manufacturing) yang butuh audit trail requirement-code-test. WAJIB dipakai sebelum menulis technical task, schema, atau API untuk fitur ERP baru. Beda dari PRD generik karena fokus rantai ID dan matrix ownership per layer.
---

# ERP BRD Traceability Framework

Framework 5-layer untuk mendokumentasikan fitur ERP/enterprise dari masalah bisnis sampai rilis, dengan setiap artefak bisa ditelusuri (traceable) ke artefak sebelum dan sesudahnya. Dipakai supaya tidak ada fitur yang "requirement-nya nggak jelas dari mana" dan tidak ada bug yang "nggak ketahuan melanggar requirement yang mana".

## Kapan pakai full chain vs ringkas

- **Fitur baru / cross-functional / butuh sign-off bisnis** (mis. Goods Receipt, approval PO, perhitungan stock) → jalankan full chain (Layer 1–5).
- **Perubahan kecil / bugfix / internal tooling** → cukup User Story + Acceptance Criteria + Technical Task (Layer 3–4), skip BRD & UAT formal.
- Kalau tidak yakin, tanya user: "ini perlu full BRD-to-UAT, atau langsung ke user story + AC saja?"

## Alur 5 Layer

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

## Skema penomoran ID

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

## Layer 1 — Business Requirement (BR)

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

## Layer 2 — Business Process (PROC)

Jelaskan alur nyata proses bisnisnya (bukan implementasi). Field yang perlu diisi: Process ID, Objective, Trigger, Actor, Precondition, Main Flow, Alternative Flow, Exception Flow, Business Rules, Output, Status/Approval, Integration.

Contoh business rule yang biasa muncul di sini:
- "PO harus APPROVED sebelum dapat dibuatkan GR."
- "Received Qty tidak boleh melebihi Outstanding Qty."
- "GR yang sudah CONFIRMED tidak boleh diedit."

Ini juga tempat menentukan status/workflow transaksi, lihat skill `erp-domain-design` untuk pola workflow status yang konsisten.

## Layer 3 — Functional Specification (US + FR + AC)

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

## Layer 4 — Technical Specification (TECH)

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

Technical Task **bukan** requirement bisnis — dia hasil turunan dari functional requirement/AC. Untuk breakdown task lebih detail dengan struktur folder/konvensi kode proyek, lanjutkan ke skill `task-breakdown` / `coding-standards`.

## Layer 5 — Testing & UAT

Setiap AC harus punya minimal satu Test Case:
```
TC-INV-001
Requirement : US-INV-001 / AC-002
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

## Ownership per layer

| Layer | Main Owner | Input dari | Approver |
|---|---|---|---|
| BRD | BA / Product Owner | Business Owner + SME | Business Owner |
| Process | BA | Process Owner + SME | Process Owner |
| Functional | BA / System Analyst | SME + Tech Lead | PO / Business Owner |
| Technical | Architect / Tech Lead | Developer + BA | Architect / Tech Lead |
| Testing | QA | BA + Dev + SME | Business User |

Hindari tiap divisi bikin BRD sendiri-sendiri untuk proses cross-functional (purchasing → warehouse → finance) — pakai centralized ownership di atas + input lintas fungsi.

## Struktur folder dokumentasi (kalau disimpan di repo)

```
docs/
├── 01-business/        (BRD.md, business-objectives.md, scope.md, stakeholders.md, glossary.md)
├── 02-process/         (per modul: purchasing/, inventory/, sales/, finance/)
├── 03-functional/      (per modul, isi user story + FR + AC)
├── 04-technical/       (architecture.md, module-boundaries.md, database.md, api.md, security.md, adr/)
└── 05-testing/         (test-cases/, integration/, uat/)
```

## Mapping ke Jira/Linear

```
Epic (mis. "Inventory Management")
  └── Feature (mis. "Goods Receipt")
        └── User Story (US-INV-001)
              ├── Technical Task (TECH-001..TECH-00N)
              └── QA Sub-task (TC-001..TC-00N)
```
Task management (Jira/Linear) mengelola pekerjaan; dokumen requirement tetap jadi sumber kebenaran untuk why/what/how/expected behavior — jangan gunakan tiket sebagai pengganti dokumen.

## Cara pakai skill ini

Kalau user minta dibuatkan requirement/BRD/user-story untuk fitur ERP:
1. Tanyakan domain modulnya (inventory/purchasing/sales/finance/manufacturing) untuk prefix ID.
2. Tanyakan level: full chain (BR→UAT) atau ringkas (US→AC→TECH saja).
3. Gali Business Problem & business rule dulu sebelum masuk ke User Story — jangan loncat.
4. Tulis output mengikuti template tiap layer di atas, dengan ID yang konsisten dan saling merujuk.
5. Kalau butuh contoh end-to-end lengkap satu fitur (Goods Receipt), baca `references/example-goods-receipt.md`.

## Posisi dalam alur wahid-toolkit

```
erp-domain-design  (desain modul/ERD dulu)
        ↓
   prd-writer      (PRD naratif untuk stakeholder)
        ↓
erp-brd-traceability (skill ini — BR→PROC→US→AC formal + ID)
        ↓
  task-breakdown    (AC & TECH di atas → task list siap dikerjakan)
        ↓
coding-standards / api-doc-standard  (saat implementasi)
        ↓
  debug-assistant   (kalau ada bug, telusuri balik ke TC/AC yang dilanggar)
        ↓
   user-guide       (dokumentasi akhir untuk end-user)
```
Untuk menjalankan seluruh alur ini otomatis dalam satu request ("bikinkan requirement sampai task untuk fitur X"), gunakan agent `erp-feature-builder`.
