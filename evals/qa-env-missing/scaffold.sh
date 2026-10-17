set -e
. "$(dirname "$0")/../base.sh"
mkdir -p web scripts
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
| Jalankan environment | `sh scripts/start-env.sh && sh scripts/migrate.sh` |
| Health check | `curl -sf http://localhost:3000/health` |
P
cat > web/checkout.js <<'J'
export async function loadDiscount(api, code) {
  const res = await fetch(`${api}/discounts/${code}`);
  if (res.status === 404) return { error: 'Kode diskon tidak ditemukan' };
  if (!res.ok) return { error: 'Gagal memuat diskon' };
  const { pct } = await res.json();
  return { pct };
}
J
cat > docs/noskill/tickets/SHOP-FE-003.md <<'T'
---
id: SHOP-FE-003
title: Tampilkan diskon di checkout
type: task
complexity: simple
status: QA
trace: —
ac: [AC-001, AC-002]
tc: []
depends_on: []
integrates_with: [SHOP-BE-002]
related: []
rounds: 0
---

## Deskripsi
Halaman checkout memuat diskon dari API `GET /discounts/:code` (tiket SHOP-BE-002, sudah DONE) dan menampilkan persentasenya.

## File/Lokasi
- web/checkout.js

## Acceptance Criteria
- [ ] AC-001: kode valid → persentase diskon dari API tampil.
- [ ] AC-002: kode tidak ada (404) → pesan "Kode diskon tidak ditemukan".

## Cara Verifikasi
Jalankan FE terhadap BE asli lalu coba kode valid dan kode yang tidak ada.

## Riwayat
- 2026-10-17 09:00 QA — review APPROVED
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
