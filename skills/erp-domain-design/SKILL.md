---
name: erp-domain-design
description: >-
  ERP/WMS domain design checklist before schema/ERD: core business, master data, stock ledger, workflow status, RBAC, audit trail, numbering, source of truth, MVP roadmap. Use for "desain ERD inventory", "modul mana dulu", or ERP/WMS PRD questions.
user-invocable: false
---

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

# ERP Domain Design (Part A)

Design principles for ERP/WMS systems so all modules stay consistent and avoid data problems ("kok stock di Sales 100, Warehouse 87, Dashboard 92?"). Use as a checklist before creating the ERD/schema/API for a new module.

### 0. Define the core business first

Before building any module, answer: "how does this company make money?" Draw the big flow first (e.g. Purchasing → Receiving → Warehouse → Production → Sales Order → Delivery → Invoice → Payment). The ERP modules needed follow this flow, not the other way around.

### 1. Master Data is the foundation — one source, used by all modules

Don't let each module keep its own item/customer table. Minimum structure:
```
Organization → Company → Branch → Department → Warehouse
Product      → Item → Category / Unit / Brand / Variant / Batch-Lot / Serial Number
Business Partner → Customer / Vendor / Employee
```
One `Item` master is used by Purchasing, Inventory, Sales, Production, Finance — not a separate copy per module.

### 2. Stock Ledger, not a stock field

**Don't** store `item.stock = 100` directly. **Use** stock movements / a ledger as the audit source:
```
StockMovement: id, item, warehouse, location, batch, type, reference, quantity, direction, created_at
```
Example entries: `PURCHASE_RECEIVE +100`, `SALES_SHIP -20`, `TRANSFER_OUT -10`, `TRANSFER_IN +10`, `ADJUSTMENT +5`.
`current_stock = SUM(semua stock movement)` — or use `stock_balances` as a performance cache, but the ledger stays the source of truth when someone asks "why does item A only have 70 left?".

### 3. Every transaction has a workflow status, not just CRUD

Purchase Order example: `DRAFT → SUBMITTED → APPROVED → PARTIALLY_RECEIVED → COMPLETED`.
Sales Order example: `DRAFT → SUBMITTED → APPROVED → PICKING → PACKING → SHIPPED → COMPLETED`.
Each transaction document should ideally have: Header, Details, Status, Approval, History, Audit Log.

### 4. RBAC, not hardcoded roles

```
User → Role → Permission
```
Avoid `if (user.role === 'ADMIN') ...` scattered through the code. Define granular per-action permissions (e.g. `inventory.goods_receipt.confirm`, `purchasing.po.approve`).

### 5. Audit Trail is mandatory for serious systems

Store at least: Who, What, When, Before, After, Reason. Example:
```
User: budi.santoso | Action: UPDATE | Module: Purchase Order | Document: PO/260920/0012
Before: quantity=100 → After: quantity=120 | Reason: Vendor confirmation
```

### 6. Centralized document numbering

Don't generate document numbers (PO/SO/GR/DO/INV) in the frontend. Build a central `document_sequence` service. Common format: `PO/2609/00001`.

### 7. Define a source of truth per entity — avoid duplicate data

```
Item        → Item Master     → dipakai Purchasing, Inventory, Sales, Production, Finance
Customer    → Customer Master → dipakai Sales, Delivery, Invoice, Payment
Stock       → Stock Ledger    → dipakai Warehouse, Sales, Purchasing, Production, Reporting
```
Sales, Warehouse, and Production must not each hold their own stock numbers that can diverge.

### 8. Design order: business flow first, then ERD

```
Business Process → Requirement → Workflow → Document → Database Model → API → UI
```
Don't jump straight to "buat Prisma schema → buat CRUD → buat frontend" without mapping the business process and workflow first.

### 9. Phased MVP roadmap — don't build 15 modules at once

| Phase | Modules |
|---|---|
| 1 — Foundation | Auth, User, Role, Permission, Company, Branch, Warehouse, Audit Log, Document Number |
| 2 — Master | Item, Category, Unit, Customer, Vendor, Warehouse, Location |
| 3 — Inventory | Opening Stock, Stock Receive/Issue/Transfer/Adjustment, Stock Ledger, Stock Balance, Batch/Lot |
| 4 — Purchasing | Purchase Request, Purchase Order, Goods Receipt, Supplier Invoice |
| 5 — Sales | Sales Order, Picking, Delivery Order, Sales Invoice |
| 6 — Finance | Account, Journal, Invoice, Payment, AR, AP |
| Later | Manufacturing, HR, Payroll, Asset, CRM, Project, Maintenance, BI |

### 10. Architecture: modular monolith first, microservices later

Start with one application (e.g. NestJS) with clearly separated modules:
```
apps/erp-api/src/modules/
  ├── iam/  ├── master-data/  ├── purchasing/  ├── inventory/
  ├── sales/  ├── finance/  ├── manufacturing/  └── audit/
```
One PostgreSQL as the starting point. Microservices only become relevant when you need independent deployment/scaling, per-service team ownership, failure isolation, a mature domain, and clear integration boundaries — not "to be modern". If business boundaries are still unclear, microservices only add complexity (network, API gateway, message broker, distributed transactions, deployment, monitoring, retries, event consistency, service discovery) while the business itself isn't stable yet.

Follow the order: `Business Capability → Bounded Context → Application Module → Technical Component`. Example: Warehouse Management → Inventory Context → Inventory Module → `StockService`, `StockMovementService`, `ReservationService`, `StockRepository`.

### 11. Inventory must be the single owner of stock, not modified directly by other modules

Wrong: `Sales → UPDATE stock` directly, `Purchasing → UPDATE stock` directly.
Right: `Purchasing → Goods Receipt → Inventory → Stock Movement → Stock Balance` and `Sales → Shipment → Inventory → Stock Movement → Stock Balance`.

### 12. Events for side-effects, not for core transactions

Events suit things like notifications/integrations after `Goods Receipt Confirmed`. But the core transaction (e.g. confirm GR + update stock) should stay within one clear transaction boundary — don't split it into a chain Service A → Event → Service B → Event → Service C if it can be done in one transaction.

## How to use

1. If the user wants to design a new ERP/WMS module/ERD, go through this checklist item by item before writing the schema.
2. If the user asks "which module first", refer to the MVP roadmap (A.9).
3. Code naming/folder structure conventions are in the `coding-standards` skill.
4. For the formal requirement document (BR→UAT), use the `erp-requirements` skill after the PRD.
