---
name: erp-requirements
description: >-
  Traceable BRD for ERP/enterprise features: BR→PROC→US→AC→TECH→TC→UAT, full or short level. Use for "buatkan BRD", "user story + AC", traceability matrix. (Domain design checklist is skill erp-domain-design.)
user-invocable: false
---

# ERP Requirements

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

This skill is the BRD traceability part (Part B). The domain design checklist before schema/ERD (Part A) is the separate skill `erp-domain-design`.

## BRD Traceability

A 5-layer framework for documenting ERP/enterprise features from business problem to release, with every artifact traceable to the artifacts before and after it. Prevents features whose "requirement came from nowhere" and bugs where "nobody knows which requirement they violate".

### When to use the full chain vs. the short form

- **New / cross-functional feature / needs business sign-off** (e.g. Goods Receipt, PO approval, stock calculation) → run the full chain (Layers 1–5).
- **Small change / bugfix / internal tooling** → User Story + Acceptance Criteria + Technical Task (Layers 3–4) is enough; skip BRD and formal UAT.
- If unsure, ask the user: "ini perlu full BRD-to-UAT, atau langsung ke user story + AC saja?"

### 5-Layer Flow

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

Core principle: **separate business needs, system behavior, and implementation.** Don't go straight from "user wants a GR menu" to "ok, build Goods Receipt CRUD". Always in order: business problem → business process → business rule → requirement → acceptance criteria → only then technical design → coding.

### ID numbering scheme

Use prefix + domain + sequence number, consistent across all layers so it can be grepped and traced:

| Layer | Prefix | Example |
|---|---|---|
| Business Requirement | `BR-<DOMAIN>-NNN` | `BR-INV-001` |
| Business Process | `PROC-<DOMAIN>-NNN` | `PROC-INV-001` |
| User Story | `US-<DOMAIN>-NNN` | `US-INV-001` |
| Functional Requirement | `FR-<DOMAIN>-NNN` | `FR-INV-001` |
| Acceptance Criteria | `AC-NNN` (under one US) | `AC-001`..`AC-005` |
| Technical Task | `TECH-NNN` (under one US) | `TECH-001`..`TECH-010` |
| Test Case | `TC-<DOMAIN>-NNN` | `TC-INV-001` |
| UAT Scenario | `UAT-<DOMAIN>-NNN` | `UAT-INV-001` |

`<DOMAIN>` is a 3-letter module code: `INV` (inventory), `PUR` (purchasing), `SLS` (sales), `FIN` (finance), `MFG` (manufacturing).

Full chain for one feature:
```
BR-INV-001 → PROC-INV-001 → US-INV-001 → [AC-001..AC-00N] → [TECH-001..TECH-00N] → [TC-001..TC-00N] → UAT-INV-001 → Release
```

### Layer 1 — Business Requirement (BR)

Answers "why is this system being built", not database/API/UI. Minimum contents:

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

Short example:
```
BR-INV-001
Business Requirement: Perusahaan membutuhkan proses penerimaan barang
yang dapat mencatat barang berdasarkan Purchase Order dan memperbarui
stock secara terkontrol.
```

### Layer 2 — Business Process (PROC)

Describe the real business process flow (not the implementation). Fields to fill: Process ID, Objective, Trigger, Actor, Precondition, Main Flow, Alternative Flow, Exception Flow, Business Rules, Output, Status/Approval, Integration.

Typical business rules here:
- "PO harus APPROVED sebelum dapat dibuatkan GR."
- "Received Qty tidak boleh melebihi Outstanding Qty."
- "GR yang sudah CONFIRMED tidak boleh diedit."

This is also where transaction status/workflow is defined; see skill `erp-domain-design` for the consistent workflow status pattern.

### Layer 3 — Functional Specification (US + FR + AC)

The business ↔ engineering bridge. Contents: User Story, Functional Requirement, Acceptance Criteria, validation, permission, status transition, notification, audit requirement, UI requirement, error handling.

**User Story** — standard format:
```
US-INV-001
Sebagai <role>,
saya ingin <aksi>,
agar <manfaat/tujuan bisnis>.
```

**Acceptance Criteria** — Given/When/Then format, one AC = one verifiable condition:
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
ACs are the **system behavior contract** — don't start technical design until the ACs fully cover: happy path, validation/reject path, side-effects (e.g. a stock movement is created), and prohibitions (e.g. confirmed data cannot be edited). For the validation path, also cover numeric limits including the database column limit (e.g. `int4`), case-insensitive/trimmed matching of codes and names, empty input, upload/import errors, and period boundaries — bugs found there after QA cost the most.

### Layer 4 — Technical Specification (TECH)

Only here do you talk architecture, ERD, API, services, transactions, authorization, events, logging. Derive Technical Tasks directly from the ACs already written — not the other way around.

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

A Technical Task is **not** a business requirement — it is derived from the functional requirement/AC. For more detailed task breakdown using the project's folder structure/code conventions, continue with the `task-breakdown` / `coding-standards` skills — `task-breakdown` maps each TECH-xxx to a Task-ID via the **Trace** column, so the traceability chain stays intact up to the task tracker.

### Layer 5 — Testing & UAT

Every AC must have at least one **positive** Test Case and, if the AC has a reject/prohibition condition, at least one **negative** Test Case. Mark the kind in the `Type` field:
```
TC-INV-001
Requirement : US-INV-001 / AC-002
Type        : Negatif
Scenario    : GR quantity melebihi outstanding
Input       : Outstanding = 30, Received = 40
Expected    : Sistem menolak transaksi.
```

UAT is done by business users; steps are the real sequence of actions:
```
UAT-INV-001
Warehouse Staff → pilih PO → input receiving → confirm
→ cek stock → cek GR → cek stock movement → approve sesuai proses bisnis.
```

### Ownership per layer

| Layer | Main Owner | Input from | Approver |
|---|---|---|---|
| BRD | BA / Product Owner | Business Owner + SME | Business Owner |
| Process | BA | Process Owner + SME | Process Owner |
| Functional | BA / System Analyst | SME + Tech Lead | PO / Business Owner |
| Technical | Architect / Tech Lead | Developer + BA | Architect / Tech Lead |
| Testing | QA | BA + Dev + SME | Business User |

Avoid each division writing its own BRD for a cross-functional process (purchasing → warehouse → finance) — use the centralized ownership above with cross-functional input.

### Documentation folder structure (if stored in the repo)

```
<docs>/
├── 01-business/        (BRD.md, business-objectives.md, scope.md, stakeholders.md, glossary.md)
├── 02-process/         (per modul: purchasing/, inventory/, sales/, finance/)
├── 03-functional/      (per modul, isi user story + FR + AC)
├── 04-technical/       (architecture.md, module-boundaries.md, database.md, api.md, security.md, adr/)
└── 05-testing/         (test-cases/, integration/, uat/)
```

### Mapping to Jira/Linear

```
Epic (mis. "Inventory Management")
  └── Feature (mis. "Goods Receipt")
        └── User Story (US-INV-001)
              ├── Technical Task (TECH-001..TECH-00N)
              └── QA Sub-task (TC-001..TC-00N)
```
Task management (Jira/Linear) manages the work; the requirement document stays the source of truth for why/what/how/expected behavior — don't use tickets as a substitute for documents.

## How to use

If the user asks for requirements/BRD/user stories for an ERP feature:
1. Ask for the module domain (inventory/purchasing/sales/finance/manufacturing) for the ID prefix.
2. Ask for the level: full chain (BR→UAT) or short (US→AC→TECH only).
3. Dig into the Business Problem and business rules before moving to User Stories — don't skip ahead.
4. Write output following each layer's template above, with consistent, cross-referencing IDs.
5. For a complete end-to-end example of one feature (Goods Receipt), read `references/example-goods-receipt.md`.

## Position in the noskill flow

```
erp-domain-design → prd-writer → erp-requirements (BRD) → task-breakdown → coding-standards → debug-assistant → user-guide (noskill-extras)
```
To run the whole flow until tickets are DONE (develop → review + verifikasi), use the `feature-flow` skill — the BRD is done by the `brd-tracer` agent, which loads this skill.
