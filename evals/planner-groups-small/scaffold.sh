set -e
. "$(dirname "$0")/../base.sh"
mkdir -p api db
cat > db/schema.sql <<'S'
CREATE TABLE brands (
  code varchar(20) PRIMARY KEY,
  name varchar(100) NOT NULL,
  monthly_quota integer NOT NULL DEFAULT 0
);
CREATE TABLE brand_channels (brand_code varchar(20) REFERENCES brands(code), channel varchar(30));
CREATE TABLE sample_usage (brand_code varchar(20), month char(7), qty integer);
S
cat > api/brands.js <<'J'
// Router brand. Endpoint baru ditambahkan di sini.
import { db } from '../lib/db.js';
export const routes = [];
J
cat > lib/db.js <<'J'
export const db = { query: async () => [] };
J
cat > docs/noskill/prd.md <<'P'
# PRD — Kuota Sample per Brand

## Core Features
1. `GET /brands` — daftar brand (code, name). Tanpa aturan khusus.
2. `GET /brands/:code` — detail satu brand (code, name, monthly_quota). Brand tidak ada → 404 `BRAND_NOT_FOUND`.
3. `GET /brands/:code/channels` — daftar channel brand. Brand tidak ada → 404 `BRAND_NOT_FOUND`.
4. `PUT /brands/:code/quota` — admin mengatur kuota sample bulanan (`monthly_quota`, bilangan bulat ≥ 0). Kuota tidak boleh lebih kecil dari pemakaian bulan berjalan (`sample_usage`) → 422 `QUOTA_BELOW_USAGE`. Nilai tidak valid → 400 `INVALID_QUOTA`. Hanya role admin; role lain → 403.

## Database
Lihat `db/schema.sql`. Kode brand ditulis user dengan huruf besar/kecil tidak konsisten (contoh: `Wardah` dan `WARDAH` adalah brand yang sama).

## Constraints
- Endpoint di `api/brands.js`. Test dengan `node --test`.
P
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm init
