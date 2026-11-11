set -e
. "$(dirname "$0")/../base.sh"
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
git checkout -q -b feat/diskon
# Tiket 1: diskon dibatasi dengan clamp. Tiket 2: voucher menghitung ulang sendiri (menduplikasi clamp, melewati applyDiscount).
cat > lib/pricing.js <<'J'
import { clamp } from './math.js';
export function applyDiscount(price, pct) {
  return price - price * clamp(pct, 0, 50) / 100;
}
J
git add -A && git -c user.name=eval -c user.email=eval@local commit -qm "SHOP-002: diskon dibatasi 0-50%"
cat > lib/voucher.js <<'J'
export function voucherPrice(price, pct) {
  const p = Math.min(Math.max(pct, 0), 50);
  return price - price * p / 100;
}
J
git add -A && git -c user.name=eval -c user.email=eval@local commit -qm "SHOP-003: harga voucher"
mkdir -p docs/noskill/tickets
for id in SHOP-002 SHOP-003; do
cat > docs/noskill/tickets/$id.md <<T
---
id: $id
title: tiket $id
type: task
complexity: simple
status: DONE
trace: —
ac: [AC-001]
tc: []
depends_on: []
related: []
rounds: 1
---

## Acceptance Criteria
- [x] AC-001: sesuai judul

## Riwayat
- 2026-10-16 09:00 TODO — dibuat
- 2026-10-16 10:00 REVIEW → DONE
T
done
