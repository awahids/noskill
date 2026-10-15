---
name: project-profile
description: >-
  Scan repo sekali lalu tulis project-profile.md di folder dokumen noskill — stack, command test/lint/typecheck/build, struktur folder, helper yang sering dipakai ulang, dan aturan dari CLAUDE.md/README — supaya agent tidak menjelajah ulang codebase di setiap tiket. Gunakan saat mulai bekerja di project baru, saat feature-flow tidak menemukan profil, atau user minta "profil project", "scan project", "refresh profil".
---

# Project Profile

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.

Tujuan: satu file ringkas yang dibaca semua agent sebelum bekerja, jadi command test, pola folder, dan helper tidak dicari ulang di setiap tiket.

## Cara scan (hemat token)

1. Baca file manifest dan konfigurasi saja, jangan seluruh source: `package.json`, `composer.json`, `go.mod`, `pyproject.toml`, `Makefile`, `docker-compose*`, file CI (`.github/workflows/*`), `CLAUDE.md`, bagian awal `README`.
2. Struktur folder: `ls` dua level teratas (abaikan `node_modules`, `vendor`, `.git`, folder build).
3. Helper umum: grep nama fungsi yang di-export di folder utilitas (`lib/`, `utils/`, `helpers/`, `pkg/`, `internal/*/util*`, `app/Helpers`). Ambil nama dan satu baris kegunaannya, jangan baca isinya penuh.
4. **Verifikasi command**: jalankan command test (dan typecheck/lint kalau ada) sekali dengan output dibatasi (`| tail -n 5`). Catat apakah lulus, berapa lama, dan cara menjalankan satu file test saja.

## Format `<docs>/project-profile.md` (maksimal ±80 baris)

```markdown
# Project Profile — <nama>
_Dibuat: <tanggal> · sumber: <commit hash pendek>_

## Stack
- Bahasa/framework/versi, database, ORM, package manager

## Command
| Tujuan | Command | Status saat scan |
|---|---|---|
| Install | `npm ci` | — |
| Test semua | `npm test` | lulus, 77 test, ±5 dtk |
| Test satu file | `npx tsx --test lib/goals.test.ts` | — |
| Typecheck | `npx tsc --noEmit` | lulus |
| Lint | `npm run lint` | lulus |
| Folder dependency (tidak di-commit) | `node_modules/` | — |

## Struktur
- `app/` — halaman Next.js (App Router)
- `lib/` — logic bisnis + unit test (`*.test.ts` di sebelah file)

## Helper yang dipakai ulang
- `lib/currency.ts` — `formatMoney(n)`: format Rupiah
- `lib/date.ts` — `todayISO()`: tanggal hari ini YYYY-MM-DD

## Aturan project
- (dikutip singkat dari CLAUDE.md/README/CI, misal: setiap perubahan yang terlihat user menambah item di `lib/changelog.ts`)

## Integrasi
- tracker: none            # none | github | notion — tujuan sinkron board tiket
- notion_database: —       # URL/ID database Notion kalau tracker: notion
```

## Aturan

- Hanya fakta yang terverifikasi dari file atau hasil command. Yang tidak yakin ditulis `belum dicek`, jangan ditebak.
- **Refresh** kalau file manifest/lockfile berubah sejak commit di header, kalau command di profil gagal dijalankan, atau user minta. Ganti bagian yang berubah saja.
- Field `tracker` diisi sesuai jawaban user (default `none`). Jangan tanyakan lagi kalau sudah terisi.
- Kalau repo itu git, sarankan user meng-commit file ini supaya sesi berikutnya langsung memakainya.
