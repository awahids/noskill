# task-breakdown

Memecah PRD menjadi daftar task development yang actionable, dikelompokkan per fase/modul/layer, dengan acceptance criteria dan dependency — khusus untuk project yang terintegrasi ke sistem existing atau menambah ke codebase yang sudah ada.

## Isinya

- Langkah memahami konteks project (greenfield vs integrasi ke existing)
- Mapping section PRD → tipe task (database, core features, integrasi, API, user flow kondisional)
- Aturan task integrasi presisi (tidak menduplikasi business logic sistem existing)
- Struktur output task (deskripsi, acuan PRD, file/lokasi, acceptance criteria, cara verifikasi, dependency, estimasi)
- Aturan penomoran Task-ID per sistem/modul
- Urutan fase yang wajar (database → backend core → API → integrasi → frontend → fitur pendukung → QA/dokumentasi)

## Kapan dipakai

Setelah PRD selesai (dari `prd-writer` atau upload user), saat diminta "buatkan task", "pecah jadi task", "breakdown PRD ini", "buat backlog dari PRD", atau "task list untuk development".

## Terkait

- `prd-writer` — sumber PRD yang jadi acuan breakdown
- `coding-standards` — struktur folder/konvensi task untuk project baru
- `standup-update` — merangkum progress setelah task dikerjakan
- `erp-brd-traceability` — untuk fitur ERP, Acceptance Criteria & Technical Task dari skill itu jadi input breakdown di sini
