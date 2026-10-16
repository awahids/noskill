set -e
. "$(dirname "$0")/../base.sh"
write_shop002 QA
cat > lib/pricing.js <<'J'
import { clamp } from './math.js';
export function applyDiscount(price, pct) {
  return price - price * Math.min(pct, 50) / 100;
}
J
cat > lib/pricing.test.js <<'J'
import { test } from 'node:test'; import assert from 'node:assert';
import { applyDiscount } from './pricing.js';
test('AC-001 positif: pct 20', () => assert.equal(applyDiscount(1000, 20), 800));
test('AC-002 batas: pct 50', () => assert.equal(applyDiscount(1000, 50), 500));
test('AC-002 negatif: pct 80 jadi 50', () => assert.equal(applyDiscount(1000, 80), 500));
J
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
