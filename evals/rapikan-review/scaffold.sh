set -e
. "$(dirname "$0")/../base.sh"
write_shop002 DONE
printf -- '- 2026-10-16 09:40 DONE — PASS\n' >> docs/noskill/tickets/SHOP-002.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
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
git add -A && git -c user.name=eval -c user.email=eval@local commit -qm "SHOP-002: Diskon dibatasi 0–50%"
