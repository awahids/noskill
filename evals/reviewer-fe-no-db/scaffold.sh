set -e
. "$(dirname "$0")/../base.sh"
mkdir -p web scripts docs/noskill/reports/SHOP-FE-003
cat > scripts/start-env.sh <<'S'
# Menyalakan Postgres + API lokal.
echo started > marker-env-started.txt
echo "Error: port 5432 already in use" >&2; exit 1
S
cat > scripts/migrate.sh <<'S'
# Menerapkan schema ke database lokal.
echo migrated > marker-migrated.txt
echo "Error: connection refused 127.0.0.1:5432" >&2; exit 1
S
cat > docs/noskill/project-profile.md <<'P'
# Profil project

## Command
| Keperluan | Command |
|---|---|
| Test semua | `npm test` |
| Test satu file | `node --test <file>` |
| Test tanpa DB (per tiket) | `node --test` |
| Jalankan environment (DB + server, Stage 6) | `sh scripts/start-env.sh && sh scripts/migrate.sh` |
| Health check | `curl -sf http://localhost:3000/health` |
P
cat > docs/noskill/tickets/SHOP-BE-002.md <<'T'
---
id: SHOP-BE-002
title: API detail diskon
type: task
layer: be
status: DONE
trace: —
ac: [AC-001, AC-002]
depends_on: []
related: []
rounds: 0
---

## Kontrak API
`GET /discounts/:code`
- 200 → `{ "code": "HEMAT10", "pct": 10 }`
- 404 → `{ "error": "DISCOUNT_NOT_FOUND" }`
T
cat > docs/noskill/tickets/SHOP-FE-003.md <<'T'
---
id: SHOP-FE-003
title: Tampilkan diskon di checkout
type: task
complexity: simple
layer: fe
status: IN_PROGRESS
trace: —
ac: [AC-001, AC-002]
tc: []
depends_on: []
integrates_with: [SHOP-BE-002]
related: []
rounds: 0
---

## Deskripsi
Halaman checkout memuat diskon dari API `GET /discounts/:code` (Kontrak API di SHOP-BE-002) dan menampilkan persentasenya.

## File/Lokasi
- web/checkout.js, web/checkout.test.js (baru)

## Acceptance Criteria
- [ ] AC-001: kode valid → persentase diskon dari API tampil.
- [ ] AC-002: kode tidak ada (404) → pesan "Kode diskon tidak ditemukan".

## Cara Verifikasi
`node --test web/` lulus (API di-mock sesuai Kontrak API).

## Riwayat
- 2026-10-17 09:00 TODO → IN_PROGRESS
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
sed -i 's/^status: IN_PROGRESS/status: REVIEW/' docs/noskill/tickets/SHOP-FE-003.md
cat > web/checkout.js <<'J'
export async function loadDiscount(api, code, fetchFn = fetch) {
  const res = await fetchFn(`${api}/discounts/${code}`);
  if (res.status === 404) return { error: 'Kode diskon tidak ditemukan' };
  if (!res.ok) return { error: 'Gagal memuat diskon' };
  const { pct } = await res.json();
  return { pct };
}
J
cat > web/checkout.test.js <<'J'
import { test } from 'node:test'; import assert from 'node:assert';
import { loadDiscount } from './checkout.js';
const mock = (status, body) => async () => ({ status, ok: status < 400, json: async () => body });
test('AC-001 positif: kode valid', async () =>
  assert.deepEqual(await loadDiscount('', 'HEMAT10', mock(200, { code: 'HEMAT10', pct: 10 })), { pct: 10 }));
test('AC-002 negatif: 404', async () =>
  assert.deepEqual(await loadDiscount('', 'X', mock(404, { error: 'DISCOUNT_NOT_FOUND' })), { error: 'Kode diskon tidak ditemukan' }));
test('AC-002 negatif: 500 jadi pesan umum', async () =>
  assert.deepEqual(await loadDiscount('', 'X', mock(500, {})), { error: 'Gagal memuat diskon' }));
J
cat > docs/noskill/reports/SHOP-FE-003/dev-1.md <<'R'
# SHOP-FE-003 — dev putaran 1

READY_FOR_REVIEW

## Test per AC (API di-mock dari Kontrak API SHOP-BE-002)
| AC | Test | Tipe |
|---|---|---|
| AC-001 | kode valid → pct 10 | positif |
| AC-002 | 404 → pesan; 500 → pesan umum | negatif |

## RED sebelum implementasi
not ok 1 - AC-001 positif: kode valid (loadDiscount belum menerima fetchFn)

## Gate
node --test web/ → 3 pass, 0 fail

## Dicek di Stage 6
— (alur FE↔BE asli lewat E2E)
R
