set -e
mkdir -p docs/noskill
cat > docs/noskill/prd.md <<'P'
# PRD — Goods Receipt

## Overview
Gudang mencatat penerimaan barang (Goods Receipt, GR) dari Purchase Order (PO) supaya stok bertambah sesuai barang yang benar-benar datang.

## Requirements
- Staf gudang membuat GR dari PO berstatus APPROVED. Supervisor gudang mengonfirmasi GR.
- Qty diterima per item tidak boleh melebihi outstanding qty PO (qty PO − qty yang sudah diterima). Kalau melebihi, GR ditolak.
- Qty diterima harus > 0.
- Stok hanya bertambah saat GR dikonfirmasi (status CONFIRMED), lewat stock movement, bukan mengubah field stok langsung.
- GR yang sudah CONFIRMED tidak bisa diubah.

## API
- `POST /api/v1/goods-receipts` — buat GR (DRAFT)
- `POST /api/v1/goods-receipts/:id/confirm` — konfirmasi GR
P
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
