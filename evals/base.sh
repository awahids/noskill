# Dipakai oleh scaffold.sh tiap case: repo kecil dengan helper clamp, kode lama berantakan, dan applyDiscount.
set -e
mkdir -p lib docs/noskill/tickets
cat > package.json <<'J'
{ "name": "demo", "type": "module", "scripts": { "test": "node --test" } }
J
cat > lib/math.js <<'J'
/** Batasi nilai v ke rentang [min, max]. */
export function clamp(v, min, max) {
  return Math.min(Math.max(v, min), max);
}
J
cat > lib/legacy.js <<'J'
export function fmtRupiah(n){ var s = String(n); var out=''; var c=0
  for (var i=s.length-1;i>=0;i--){ out = s[i]+out; c++; if(c%3==0 && i>0) out='.'+out }
  return 'Rp '+out }
J
cat > lib/pricing.js <<'J'
export function applyDiscount(price, pct) {
  return price - price * pct / 100;
}
J

# Tiket SHOP-002 (diskon 0–50%) dengan status tertentu; dipakai case QA dan rapikan review.
write_shop002() {
cat > docs/noskill/tickets/SHOP-002.md <<T
---
id: SHOP-002
title: Diskon dibatasi 0–50%
type: task
complexity: simple
status: $1
trace: —
ac: [AC-001, AC-002, AC-003]
tc: []
depends_on: []
related: []
rounds: 0
---

## Deskripsi
\`applyDiscount(price, pct)\` harus membatasi pct ke rentang 0 sampai 50.

## File/Lokasi
lib/pricing.js, lib/pricing.test.js

## Acceptance Criteria
- [ ] AC-001: pct 0–50 → hasil seperti sekarang
- [ ] AC-002: pct > 50 → diperlakukan sebagai 50
- [ ] AC-003: pct < 0 → diperlakukan sebagai 0 (harga tidak boleh naik)

## Cara Verifikasi
\`npm test\` lulus

## Riwayat
- 2026-10-16 09:00 TODO — dibuat
- 2026-10-16 09:05 IN_PROGRESS — dikirim ke developer
T
}
