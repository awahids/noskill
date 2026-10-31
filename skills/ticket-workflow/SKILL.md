---
name: ticket-workflow
description: >-
  noskill ticket file format and status flow (TODO → IN_PROGRESS → REVIEW → QA → DONE, plus BUG and HOLD), agent verdicts, and the board. Use when creating, moving, or reporting tickets, or when the user asks "status tiket" or "board tiket".
user-invocable: false
---

# Ticket Workflow

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

Shared contract for all tickets in `<docs>/tickets/`. Every skill and agent that touches tickets follows these rules, so ticket status means the same thing at every stage.

## Status Flow

```
TODO ──► IN_PROGRESS ──► REVIEW ──► QA ──► DONE
              ▲             │        │
              │   revisi    │        │ gagal test
              ├─────────────┘        ▼
              └──────────────────── BUG

Status apa pun ──► HOLD  (butuh keputusan user / blocker eksternal)
HOLD ──► status sebelum HOLD, setelah blocker selesai
```

| Status | Meaning | Processed by | Exits to |
|---|---|---|---|
| `TODO` | Ready to work, all `depends_on` are DONE | developer | IN_PROGRESS |
| `IN_PROGRESS` | Being worked / revised | developer | REVIEW, HOLD |
| `REVIEW` | Code done, checked against the ticket | ticket-reviewer | QA, IN_PROGRESS, HOLD |
| `QA` | Passed review, tested against AC & Test Cases. Tickets with `integrates_with` wait here until their paired ticket is DONE | qa-tester | DONE, BUG, HOLD |
| `BUG` | Failed QA — bug report in Riwayat | developer (using `debug-assistant`) | IN_PROGRESS |
| `HOLD` | Stopped: ambiguous requirement, needs user decision, environment/access unavailable, or 3 failed rounds | user | previous status |
| `DONE` | Passed QA, changes committed | — | — |

## Transition Rules

1. **Only the orchestrator (`feature-flow`) changes the `status` and `rounds` fields and writes `## Riwayat`.** Other agents return a verdict; the orchestrator moves the ticket. One writer = no overwritten statuses.
2. **One ticket per working directory**, so `git diff` during review/QA contains only that ticket's changes. Sequential mode: tickets take turns on the working branch. Parallel mode: each active ticket has its own git worktree. Multi-repo: the ticket is worked in the repo named in its `repo` field (see `feature-flow`).
3. **Pick order:** `BUG` first, then `TODO` whose `depends_on` are all DONE, BE tickets before FE tickets, by ID. Tickets depending on a HOLD ticket are not picked. `integrates_with` doesn't block work — only QA (rule 7).
4. **`rounds` increases by 1** each time a ticket returns to the developer (REVIEW → IN_PROGRESS or QA → BUG). When `rounds` reaches 3, the ticket moves to **HOLD** — three failed rounds mean the problem is in the requirement/design, not the code, and needs a user decision.
5. **No status is skipped.** No ticket goes directly from IN_PROGRESS to QA, or from REVIEW to DONE.
6. **DONE needs evidence.** QA may PASS only if every AC and TC of the ticket was actually run and the result is visible (test/command output), not "should be correct".
7. **BE–FE joint QA.** A ticket with `integrates_with` is QA'd only after all tickets in that list are DONE, then tested together with them (FE calls the real BE). The Kontrak API is changed only by the orchestrator, recorded in both tickets' Riwayat.

## Agent Verdicts

Agents return the verdict on the first line of their answer, then details:

| Agent | Verdict | Next status |
|---|---|---|
| developer | `READY_FOR_REVIEW` | REVIEW |
| developer | `BLOCKED: <alasan>` | HOLD |
| ticket-reviewer | `APPROVED` | QA |
| ticket-reviewer | `CHANGES_REQUESTED` + list of changes | IN_PROGRESS |
| ticket-reviewer | `BLOCKED: <alasan>` | HOLD |
| qa-tester | `PASS` + evidence per AC/TC | DONE |
| qa-tester | `FAIL` + bug report | BUG |
| qa-tester | `BLOCKED: <alasan>` | HOLD |

`BLOCKED` is only for things the agent can't resolve itself (conflicting/ambiguous requirement, missing access/env, business decision). Wrong code is not BLOCKED — it's CHANGES_REQUESTED or FAIL.

## Ticket File Format

One file per ticket: `<docs>/tickets/<ID>.md`. IDs follow the `task-breakdown` numbering rules (e.g. `WMS-BE-004`); new bugs from QA use `BUG-NNN`. One ticket changes only one repo.

```markdown
---
id: WMS-BE-004
title: Validasi outstanding quantity saat Goods Receipt
type: task            # task | bug
complexity: simple    # simple | complex — menentukan model developer (lihat di bawah)
layer: be             # be | fe | — — menentukan agent developer (lihat di bawah)
repo: api             # opsional, hanya untuk fitur multi-repo: nama repo dari bagian Repo di project-profile
status: TODO
trace: US-INV-001 / TECH-003   # dari dokumen BRD (erp-requirements), "—" kalau tidak ada
ac: [AC-002]
tc: [TC-INV-002]
depends_on: [WMS-BE-001]   # harus DONE sebelum tiket ini dikerjakan
integrates_with: []       # tiket FE: ID tiket BE yang kontraknya dipakai; dikerjakan bareng, QA bareng setelah BE DONE
related: []           # untuk tiket bug: tiket asal
rounds: 0
tracker_ref: —        # opsional: nomor issue GitHub / URL Notion kalau tracker aktif
---

## Deskripsi
[apa yang dikerjakan, 1-3 kalimat]

## Acuan
[section PRD / dokumen BRD terkait]

## File/Lokasi
[path konkret di project — multi-repo: relatif terhadap root repo tiket]

## Kontrak API
<!-- wajib untuk tiket BE yang menambah/mengubah endpoint; tiket FE cukup menulis "lihat <ID tiket BE>" -->
`POST /api/v1/goods-receipts`
- Request: `{ poId: number, items: [{ itemId: number, receivedQty: number > 0 }] }`
- 201: `{ data: { id, number, status: "DRAFT" } }`
- 422 `QTY_EXCEEDS_OUTSTANDING`: receivedQty > outstanding
- 404 `PO_NOT_FOUND`

## Acceptance Criteria
- [ ] AC-002: Received qty > outstanding qty → transaksi ditolak

## Cara Verifikasi
[command/langkah konkret yang membuktikan tiket selesai]

## Catatan
<!-- opsional: temuan pembuat tiket saat membaca kode, supaya developer tidak mencari ulang -->
- Helper yang dipakai ulang: `lib/stock/outstanding.ts` — `getOutstandingQty(poId, itemId)`
- Pola yang diikuti: `src/modules/goods-receipt/goods-receipt.service.ts` (validasi di service, bukan controller)
- Test yang sudah ada: `src/modules/goods-receipt/goods-receipt.service.spec.ts`

## Riwayat
- 2026-10-14 09:12 TODO — dibuat oleh task-planner
```

**complexity** is set when the ticket is created:
- `simple` — bug with a clear cause, CRUD endpoint without special business rules, UI change without complex state logic, roughly ≤ 4 files.
- `complex` — business rules (stock, money, approval/workflow status), transactions or concurrency, many tables, or bug cause still unknown. If unsure, use `complex`.

**layer** is set when the ticket is created and picks the developer agent: `be` → `backend-developer` (API, service, migration, job), `fe` → `frontend-developer` (pages, components, state), `—` or empty → `developer` (fullstack monolith, mobile, scripts, config, or tickets made before this field existed). "developer" elsewhere in this skill means whichever of the three the ticket's `layer` picks.

**Riwayat** is append-only, one line per status change: `- <YYYY-MM-DD HH:MM> <STATUS> — <ringkasan alasan>` (time from `date '+%Y-%m-%d %H:%M'`, used by `/noskill:tiket board` to compute each stage's duration). For changes to BUG/HOLD/IN_PROGRESS (revision), add a 1–3 line summary beneath it (indented) with the agent report path, or the question for the user.

**Agent reports** are stored in `<docs>/reports/<ID>/` — `dev-<n>.md`, `review-<n>.md`, `qa-<n>.md` (n = round). Riwayat only references the path, it doesn't copy the contents.

## Bug Report (QA → BUG)

```markdown
- 2026-10-14 14:05 BUG — TC-INV-002 gagal (laporan: <docs>/reports/WMS-BE-004/qa-1.md)
  - **Langkah:** POST /api/v1/goods-receipts dengan outstanding=30, received=40
  - **Expected:** 422, transaksi ditolak
  - **Actual:** 201, GR tersimpan
  - **Bukti:** [output command/test]
```

If QA finds a bug **outside this ticket's AC** (regression in another feature), don't fail this ticket for it — create a new ticket `type: bug`, `status: BUG`, `related: [<tiket asal>]`. If the correct behavior for that bug isn't defined in the requirements (no AC that can serve as Expected), its initial status is `HOLD` with a question to the user, not `BUG` — the developer can't fix it without a spec.

## Board

Show the board from the `status` field of all ticket files (`grep -H "^status:" <docs>/tickets/*.md`), grouped by column: TODO · IN_PROGRESS · REVIEW · QA · BUG · HOLD · DONE. Multi-repo: write the repo next to the ID (`WMS-FE-002 [web]`). The board is not saved as a separate file — ticket files are the only source of truth.
