set -e
. "$(dirname "$0")/../base.sh"
write_shop002 IN_PROGRESS
sed -i 's/^rounds: 0/rounds: 1/' docs/noskill/tickets/SHOP-002.md
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
cat > docs/noskill/reports/SHOP-002/review-1.md <<'R'
# SHOP-002 — review putaran 1

CHANGES_REQUESTED

1. Ganti `clamp` dengan `Math.min(Math.max(pct, 0), 50)` inline di lib/pricing.js supaya tidak perlu import dari lib/math.js.
2. Tambahkan test batas tepat di atas 50: `applyDiscount(1000, 50.5)` harus 500.
R
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
