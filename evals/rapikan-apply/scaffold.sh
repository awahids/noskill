set -e
. "$(dirname "$0")/../base.sh"
cat > docs/noskill/prd.md <<'P'
# PRD — Batas Diskon
## Core Features
1. `applyDiscount(price, pct)` di `lib/pricing.js` membatasi pct ke 0–50: di atas 50 jadi 50, negatif jadi 0.
2. `fmtRupiah(n)` di `lib/legacy.js` sudah ada dan sudah selesai (tidak berubah).
P
t() { cat > "docs/noskill/tickets/$1.md"; }
t SHOP-001 <<'T'
---
id: SHOP-001
title: Tambah konstanta MAX_DISCOUNT = 50
type: task
status: TODO
trace: —
ac: []
tc: []
depends_on: []
related: []
rounds: 0
---
## Deskripsi
Tambah konstanta batas diskon.
## File/Lokasi
src/
## Acceptance Criteria
- [ ] Konstanta MAX_DISCOUNT ada
## Riwayat
- 2026-10-14 TODO — dibuat oleh task-planner
T
t SHOP-002 <<'T'
---
id: SHOP-002
title: Batasi pct di applyDiscount
type: task
status: TODO
trace: —
ac: []
tc: []
depends_on: [SHOP-001]
related: []
rounds: 0
---
## Deskripsi
applyDiscount memakai MAX_DISCOUNT untuk membatasi pct.
## File/Lokasi
lib/pricing.js
## Acceptance Criteria
- [ ] pct 60 → diperlakukan 50
## Riwayat
- 2026-10-14 TODO — dibuat oleh task-planner
T
t SHOP-003 <<'T'
---
id: SHOP-003
title: Tulis unit test applyDiscount
type: task
status: TODO
trace: —
ac: []
tc: []
depends_on: [SHOP-002]
related: []
rounds: 0
---
## Deskripsi
Unit test untuk applyDiscount.
## File/Lokasi
test/
## Acceptance Criteria
- [ ] Test ada dan lulus
## Riwayat
- 2026-10-14 TODO — dibuat oleh task-planner
T
t SHOP-004 <<'T'
---
id: SHOP-004
title: Format Rupiah
type: task
status: DONE
trace: —
ac: []
tc: []
depends_on: []
related: []
rounds: 0
---
## File/Lokasi
lib/legacy.js
## Riwayat
- 2026-10-13 DONE — PASS
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
