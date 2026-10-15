# mockup-prototype

Membuat mockup/prototype UI (HTML atau React interaktif) berdasarkan PRD yang sudah ada — menerjemahkan Core Features, User Flow, dan Requirements/RBAC di PRD menjadi wireframe/mockup per layar dan per role.

## Isinya

- Alur kerja: ekstrak daftar layar dari PRD → tentukan fidelity (wireframe/mockup/prototype) → cek design system existing → build mockup → review pass akhir → anotasi singkat
- Aturan merefleksikan PRD ke mockup (field sesuai schema, state kosong/loading/error, pembatasan akses role di UI)
- Checklist review kualitas visual (spacing, hierarki, kontras, konsistensi, accessibility)

## Kapan dipakai

Setiap kali diminta "buatkan mockup", "buatkan prototype", "wireframe untuk PRD ini", "desain UI dari requirement ini", atau setelah PRD selesai dan mau lanjut ke tahap visual.

## Terkait

- `prd-writer` — sumber PRD yang jadi acuan
- `frontend-design` (built-in) — prinsip visual, tipografi, styling
- `coding-standards` — struktur komponen/naming kalau mockup dilanjutkan jadi kode production
