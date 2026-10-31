set -e
. "$(dirname "$0")/../base.sh"
cat > docs/noskill/tickets/SHOP-003.md <<'T'
---
id: SHOP-003
title: Diskon tidak boleh membuat harga negatif
type: task
complexity: simple
layer: be
status: IN_PROGRESS
trace: —
ac: [AC-001, AC-002]
tc: []
depends_on: []
related: []
rounds: 0
---

## Deskripsi
`applyDiscount(price, pct)` tidak boleh mengembalikan harga di bawah 0.

## File/Lokasi
lib/pricing.js, lib/pricing.test.js (baru)

## Acceptance Criteria
- [ ] AC-001: pct 0–100 → hasil seperti sekarang
- [ ] AC-002: pct > 100 → hasil 0, bukan negatif

## Cara Verifikasi
`npm test` lulus

## Riwayat
- 2026-10-31 09:00 IN_PROGRESS — dikirim ke developer
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
