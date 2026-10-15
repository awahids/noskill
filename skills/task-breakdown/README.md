# task-breakdown

Memecah PRD atau BRD menjadi tiket development: satu tiket per endpoint (BE, dengan Kontrak API), per fitur/halaman (FE), atau per bug — tidak per layer. Setiap tiket punya acceptance criteria, cara verifikasi, dan dependency, dan menyesuaikan codebase yang sudah ada.

## Isinya

- Langkah memahami konteks project (greenfield vs integrasi ke existing)
- Aturan tiket per endpoint/fitur/bug, Kontrak API, dan `integrates_with` untuk pasangan BE–FE
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
