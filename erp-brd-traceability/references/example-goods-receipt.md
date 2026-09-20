# Contoh End-to-End: Goods Receipt (Inventory)

Contoh lengkap satu fitur dari BR sampai UAT, dipakai sebagai referensi format ketika membuat dokumen requirement baru.

## BR-INV-001
Business Requirement: Warehouse membutuhkan proses penerimaan barang berdasarkan
Purchase Order agar stock tercatat sesuai barang yang benar-benar diterima.

## PROC-INV-001
```
PO Approved → Barang datang → Warehouse melakukan Receiving →
Check Quantity → Confirm GR → Stock bertambah
```
Business rules:
- PO harus APPROVED sebelum dapat dibuatkan GR.
- Received Qty tidak boleh melebihi Outstanding Qty.
- GR yang sudah CONFIRMED tidak boleh diedit.
- GR CONFIRMED harus menghasilkan Stock Movement.

## US-INV-001
Sebagai Warehouse Staff, saya ingin membuat Goods Receipt berdasarkan PO, agar
barang yang diterima dapat tercatat dan stock bertambah secara otomatis.

## Acceptance Criteria
```
AC-001
Given PO sudah Approved
When Warehouse membuat Goods Receipt
Then sistem menampilkan item dan outstanding quantity.

AC-002
Given outstanding quantity = 30
When user memasukkan quantity = 40
Then sistem menolak transaksi.

AC-003
Given Goods Receipt valid
When user melakukan Confirm
Then sistem menambah stock.

AC-004
Given Goods Receipt berhasil di-confirm
Then sistem membuat Stock Movement.

AC-005
Given Goods Receipt sudah Confirmed
When user mencoba mengedit
Then sistem menolak perubahan.
```

## Technical Design & Tasks
```
US-INV-001
  ├── Backend
  │    ├── POST /goods-receipts
  │    ├── GET /goods-receipts/:id
  │    └── POST /goods-receipts/:id/confirm
  ├── Database
  │    ├── goods_receipts
  │    ├── goods_receipt_items
  │    └── stock_movements
  ├── Business Logic
  │    ├── validateOutstandingQty()
  │    ├── validateBatch()
  │    └── confirmGoodsReceipt()
  └── Frontend
       ├── GR List
       ├── GR Detail
       └── GR Form

TECH-001  Create goods_receipts model
TECH-002  Create goods_receipt_items model
TECH-003  Implement POST /goods-receipts
TECH-004  Implement outstanding quantity validation
TECH-005  Implement GR confirmation transaction
TECH-006  Create stock movement when GR confirmed
TECH-007  Create Goods Receipt form
TECH-008  Create Goods Receipt detail page
TECH-009  Add permission inventory.goods_receipt.confirm
```

## Test Case & UAT
```
TC-INV-002
Requirement : US-INV-001 / AC-002
Scenario    : GR quantity melebihi outstanding
Input       : Outstanding = 30, Received = 40
Expected    : System rejects transaction.

UAT-INV-001
Warehouse Staff → pilih PO → input receiving → confirm
→ cek stock → cek GR → cek stock movement → approve bahwa proses sesuai bisnis.
```

## Trace penuh
```
BR-INV-001 → PROC-INV-001 → US-INV-001
  ├── AC-001..AC-005
  ├── TECH-001..TECH-009
  ├── TC-INV-001..TC-INV-00N
  └── UAT-INV-001 → Release
```
Kalau nanti ada bug, telusuri balik: Bug → Test Case → Acceptance Criteria → User Story → Business Requirement, untuk tahu requirement mana yang dilanggar.
