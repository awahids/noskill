set -e
. "$(dirname "$0")/../base.sh"
cat > docs/noskill/tickets/SHOP-002.md <<'T'
---
id: SHOP-002
title: Diskon dibatasi 0–50%
type: task
status: IN_PROGRESS
trace: —
ac: [AC-001, AC-002, AC-003]
tc: []
depends_on: []
related: []
rounds: 0
---

## Deskripsi
`applyDiscount(price, pct)` harus membatasi pct ke rentang 0 sampai 50.

## File/Lokasi
lib/pricing.js, lib/pricing.test.js (baru)

## Acceptance Criteria
- [ ] AC-001: pct 0–50 → hasil seperti sekarang
- [ ] AC-002: pct > 50 → diperlakukan sebagai 50
- [ ] AC-003: pct < 0 → diperlakukan sebagai 0 (harga tidak boleh naik)

## Cara Verifikasi
`npm test` lulus

## Riwayat
- IN_PROGRESS — dikirim ke developer
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
sed -i 's/IN_PROGRESS/REVIEW/' docs/noskill/tickets/SHOP-002.md
cat > lib/pricing.js <<'J'
export function applyDiscount(price, pct) {
  const p = Math.min(50, Math.max(0, pct));
  return price - price * p / 100;
}
J
cat > lib/pricing.test.js <<'J'
import { test } from 'node:test'; import assert from 'node:assert';
import { applyDiscount } from './pricing.js';
test('applies discount', () => assert.equal(applyDiscount(1000, 20), 800));
J
