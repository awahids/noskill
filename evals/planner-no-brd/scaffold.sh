set -e
. "$(dirname "$0")/../base.sh"
cat > docs/noskill/prd.md <<'P'
# PRD — Aturan Harga Toko

## Core Features
1. **Batas diskon.** `applyDiscount(price, pct)` di `lib/pricing.js` membatasi pct ke 0–50. Diskon di atas 50 diperlakukan sebagai 50; diskon negatif diperlakukan sebagai 0 (harga tidak boleh naik).
2. **Gratis ongkir.** Fungsi baru `shippingFee(subtotal)` di `lib/pricing.js`: subtotal ≥ 100000 → 0, di bawahnya → 15000. Subtotal negatif ditolak (throw error).

## Constraints
- Pakai helper yang sudah ada di `lib/`. Test dengan `node --test`.
P
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
