---
name: project-profile
description: >-
  Scans the repo once and writes project-profile.md (stack, test/lint/typecheck commands, folders, helpers, rules) so agents don't re-explore per ticket. Use on new projects, when feature-flow finds no profile, or for "profil project", "scan project".
---

# Project Profile

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

Goal: one compact file every agent reads before working, so test commands, folder patterns, and helpers aren't searched again on every ticket. Use when starting work on a new project, when feature-flow finds no profile, or when the user asks.

## How to scan (token-efficient)

1. Read only manifest and config files, not all source: `package.json`, `composer.json`, `go.mod`, `pyproject.toml`, `Makefile`, `docker-compose*`, CI files (`.github/workflows/*`), `CLAUDE.md`, the top of `README`.
2. Folder structure: `ls` the top two levels (ignore `node_modules`, `vendor`, `.git`, build folders).
3. Common helpers: grep exported function names in utility folders (`lib/`, `utils/`, `helpers/`, `pkg/`, `internal/*/util*`, `app/Helpers`). Record the name and a one-line purpose; don't read them in full.
4. **Verify commands**: run the test command (and typecheck/lint if present) once with limited output (`| tail -n 5`). Record whether it passes, how long it takes, and how to run a single test file.
5. **Fast versions** for per-ticket use, with cache in `.noskill-cache/` (add `.noskill-cache/` to `.git/info/exclude`, not `.gitignore`, so it isn't committed). Check once that the fast version works, then record:
   - TypeScript: `npx tsc --noEmit --incremental --tsBuildInfoFile .noskill-cache/tsc.tsbuildinfo` (second and later runs only recheck changed files)
   - ESLint: `npx eslint --cache --cache-location .noskill-cache/eslint <file>`
   - Jest: `npx jest --findRelatedTests <file>`; Vitest: `npx vitest related <file> --run`
   - Go: `go vet ./<paket>/...` and `go test ./<paket>/...` (Go already uses its own cache)
   - PHP: PHPStan and Pest/PHPUnit with a file filter or related tests
   If the fast version fails or the tool version doesn't support it, write `belum dicek` and use the normal version.

## `<docs>/project-profile.md` format (max ±80 lines)

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
| Test terkait file yang diubah | `npx jest --findRelatedTests <file>` | — |
| Lint file tertentu | `npx eslint --cache --cache-location .noskill-cache/eslint <file>` | — |
| Jalankan environment (DB + server, untuk QA) | `docker compose up -d db && npm run start:dev` | — |
| Health check | `curl -sf localhost:3000/health` | — |
| Typecheck | `npx tsc --noEmit` | lulus |
| Typecheck cepat (per tiket) | `npx tsc --noEmit --incremental --tsBuildInfoFile .noskill-cache/tsc.tsbuildinfo` | lulus, ±3 dtk setelah run pertama |
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

## Repo (hanya kalau fitur menyentuh beberapa repo)
| Nama | Path | Profil |
|---|---|---|
| api | . | project-profile.md |
| web | ../web-client | project-profile-web.md |

## Integrasi
- tracker: none            # none | github | notion — tujuan sinkron board tiket
- notion_database: —       # URL/ID database Notion kalau tracker: notion
```

## Rules

- Only facts verified from files or command output. Anything uncertain is written `belum dicek`, never guessed.
- **Refresh** if a manifest/lockfile changed since the commit in the header, if a command in the profile fails, or if the user asks. Replace only the changed parts.
- The `tracker` field is filled from the user's answer (default `none`). Don't ask again once it's filled.
- **Other repos (multi-repo):** scan that repo the same way (path from the Repo section), but save the result in the docs repo as `<docs>/project-profile-<nama>.md` without the Repo and Integrasi sections. Other repos get no noskill folder.
- If the repo is git, suggest the user commit this file so the next session uses it directly.
