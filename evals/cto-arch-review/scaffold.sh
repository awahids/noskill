set -e
. "$(dirname "$0")/../base.sh"
cat > docs/noskill/prd.md <<'P'
# PRD — Voucher Diskon

**Version:** 1.0
**Status:** Approved
**Sistem:** bagian dari toko demo (lib/pricing.js)

## Overview
Pelanggan memasukkan kode voucher saat checkout. Voucher memberi potongan persen dan punya kuota pemakaian total, misalnya 100 kali.

## Aturan Bisnis
- Potongan voucher memakai perhitungan diskon yang sudah ada (`applyDiscount` di lib/pricing.js) dan dibatasi 0–50%.
- Kuota voucher berkurang 1 setiap checkout sukses. Voucher yang kuotanya habis ditolak.
- Checkout bisa terjadi bersamaan dari banyak pelanggan.

## Database
Tabel `vouchers` (code, pct, quota_left).
P
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
