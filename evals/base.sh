# Dipakai oleh scaffold.sh tiap case: repo kecil dengan helper clamp, kode lama berantakan, dan applyDiscount.
set -e
mkdir -p lib docs/tickets
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
