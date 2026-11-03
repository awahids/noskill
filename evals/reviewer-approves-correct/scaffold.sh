set -e
. "$(dirname "$0")/../base.sh"
write_shop002 IN_PROGRESS
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
sed -i 's/^status: IN_PROGRESS/status: REVIEW/' docs/noskill/tickets/SHOP-002.md
cat > lib/pricing.js <<'J'
import { clamp } from './math.js';
export function applyDiscount(price, pct) {
  return price - price * clamp(pct, 0, 50) / 100;
}
J
cat > lib/pricing.test.js <<'J'
import { test } from 'node:test'; import assert from 'node:assert';
import { applyDiscount } from './pricing.js';
test('AC-001 positif: pct 20', () => assert.equal(applyDiscount(1000, 20), 800));
test('AC-002 batas: pct 50', () => assert.equal(applyDiscount(1000, 50), 500));
test('AC-002 negatif: pct 80 jadi 50', () => assert.equal(applyDiscount(1000, 80), 500));
test('AC-003 batas: pct 0', () => assert.equal(applyDiscount(1000, 0), 1000));
test('AC-003 negatif: pct -10 jadi 0', () => assert.equal(applyDiscount(1000, -10), 1000));
J
mkdir -p docs/noskill/reports/SHOP-002
cat > docs/noskill/reports/SHOP-002/dev-1.md <<'R'
# SHOP-002 — dev putaran 1

READY_FOR_REVIEW

## Rencana
- Ubah lib/pricing.js; pakai helper `clamp` dari lib/math.js (grep `clamp|min|max`). Alternatif `Math.min/Math.max` inline ditolak: duplikasi helper.

## Test per AC
| AC | Test | Tipe |
|---|---|---|
| AC-001 | pct 20 | positif |
| AC-002 | pct 50 / pct 80 | batas / negatif |
| AC-003 | pct 0 / pct -10 | batas / negatif |

## RED sebelum implementasi
not ok 3 - AC-002 negatif: pct 80 jadi 50
not ok 5 - AC-003 negatif: pct -10 jadi 0

## Gate
npm test → 5 pass, 0 fail

## Dicek di Stage 6
—
R
