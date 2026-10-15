set -e
. "$(dirname "$0")/../base.sh"
cat > docs/noskill/prd.md <<'P'
# PRD — Batas Diskon

## Core Features
1. **API (repo `api`):** endpoint baru `POST /api/discount`, body `{ price: number, pct: number }`. Memakai `applyDiscount` di `lib/pricing.js`. Sukses → 200 `{ finalPrice }`. pct > 50 → 422 dengan kode `DISCOUNT_TOO_HIGH`. pct < 0 → 422 dengan kode `INVALID_DISCOUNT`.
2. **Web (repo `web`):** form diskon di `src/discount-form.js` memanggil endpoint itu, menampilkan `finalPrice` dari respons, dan menampilkan "Diskon maksimal 50%" kalau respons 422 `DISCOUNT_TOO_HIGH`. Harga akhir tidak dihitung ulang di web.
P
cat > docs/noskill/project-profile.md <<'P'
# Project Profile — api
## Stack
- Node.js ESM, test `node --test`
## Command
| Tujuan | Command |
|---|---|
| Test semua | `npm test` |
## Repo
| Nama | Path | Profil |
|---|---|---|
| api | . | project-profile.md |
| web | web | project-profile-web.md |
P
cat > docs/noskill/project-profile-web.md <<'P'
# Project Profile — web
## Stack
- JavaScript ESM tanpa framework, test `node --test`
## Struktur
- `src/` — komponen UI; `src/api.js` — `postDiscount(price, pct)` memanggil API
P
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
echo "web/" >> .git/info/exclude
mkdir -p web/src && cd web
cat > package.json <<'J'
{ "name": "web", "type": "module", "scripts": { "test": "node --test" } }
J
cat > src/api.js <<'J'
export async function postDiscount(price, pct) {
  const r = await fetch('/api/discount', { method: 'POST', body: JSON.stringify({ price, pct }) });
  return r.json();
}
J
cat > src/discount-form.js <<'J'
import { postDiscount } from './api.js';
export async function submitDiscount(price, pct) {
  return postDiscount(price, pct);
}
J
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
