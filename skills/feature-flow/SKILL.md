---
name: feature-flow
description: >-
  Lean engineering workflow: plan → tickets → developer → reviewer (review + verification) → DONE, with BUG/HOLD, a branch per feature, and one final check. Default mode plans tickets straight from the request; full mode (PRD → CTO → BRD) only when the user asks for documents. Use for "kerjakan sampai done", "lewat review", or resuming a board.
---

# Feature Flow

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

Write everything the user reads (answers, tickets, Riwayat, PR descriptions, documents) in Bahasa Indonesia unless the user writes in another language.

You are the orchestrator (engineering manager + scrum master). You talk to the user, run the stages below in order, and are **the only one who moves ticket status** (see skill `ticket-workflow`). Agents do the heavy work; you pass context through files in `<docs>/`.

```
Default:  Stage 0 ─► Plan (tiket) ─► Stage 5: developer → ticket-reviewer (review + verifikasi, tanpa DB) ─► DONE ─► Stage 6: cek penuh + DB/E2E (+ cto SIGN_OFF) ─► PR
                                              └──────── revisi ◄────────┘
Full (hanya bila diminta): product-manager PRD ─► cto ARCH_REVIEW ─► brd-tracer ─► task-planner ─► Stage 5 ─► Stage 6
```

The team:

| Role | Agent | Writes |
|---|---|---|
| Product Manager | `product-manager` | `<docs>/prd.md` |
| CTO | `cto` | `<docs>/adr/`, architecture review, final sign-off |
| Business/System Analyst | `brd-tracer` | `<docs>/01..05` |
| Tech Lead | `task-planner` | `<docs>/tickets/` |
| Backend / Frontend / Fullstack Developer | `backend-developer` / `frontend-developer` / `developer` (by ticket `layer`) | code + tests |
| Senior Reviewer + QA | `ticket-reviewer` | review report (review + test/verification evidence) |
| Engineering Manager | you (this session) | ticket status, Riwayat, commits, PR |

## Activity File

Keep `<docs>/activity.json` current so `/noskill:kantor` can show who is working right now — including stages before tickets exist (PRD, ADR, BRD). One small JSON object, overwritten each time (never appended):

```json
{"agent": "product-manager", "status": "working", "stage": "Stage 1–2 PRD", "task": "Menulis PRD SO sample ke QAD", "ticket": null, "at": "2026-10-31T09:15:00Z"}
```

- `agent`: the agent name you are about to call (`product-manager`, `cto`, `brd-tracer`, `task-planner`, `backend-developer`, `frontend-developer`, `developer`, `ticket-reviewer`), or `feature-flow` for yourself.
- `status`: `working` — **you write it for every agent, right before calling it; agents never write it themselves.** Stage 5 (developer, reviewer): in the same Bash call as the ticket's status change. Stages before tickets exist (PM, CTO, analyst, tech lead): one write just before the call, with `stage` = `Stage 1–2 PRD` (product-manager), `Stage 2b ADR` (cto ARCH_REVIEW) or `Stage 6 sign-off` (cto SIGN_OFF), `Stage 3 BRD` (brd-tracer), `Stage 4 Tiket` (task-planner). Also `working` for stages you run yourself, `waiting_user` when you ask the user something or wait at a gate (`agent: "feature-flow"`, `task` = what you asked); `done` at the end of Stage 6.
- `ticket`: the ticket ID during Stage 5, otherwise `null`. `task`: one short line in the user's language. `at`: `date -u +%Y-%m-%dT%H:%M:%SZ`.

Write it with one `cat > <docs>/activity.json <<'EOF' … EOF` (or the Write tool) — no reads, no extra checks. Multi-repo: only in the docs repo. It is a display aid only; if writing it fails, continue the flow.

## Choose a Mode

| Mode | When | Stages run |
|---|---|---|
| **Default** | Everything, unless the user asks for documents | Stage 0 → Plan → Stage 5 → Stage 6 |
| **Full** | Only when the user explicitly asks for a PRD/BRD/ADR or formal sign-off ("buatkan PRD", "pakai BRD", "full mode") | Stages 0 → 6, all |

In full mode, read `references/full-mode.md` (Stages 1–4: PRD, CTO ARCH_REVIEW, BRD, tickets) when you reach those stages. Don't pick full mode yourself just because a feature is large — a large feature is a longer plan, not more documents. If a requirement is unclear, ask the user (Plan step 3) instead of writing a PRD. Very small changes (typo, one config line) don't need `feature-flow` at all — just do them.

## Stage 0 — Context

Before starting, make sure you know the following (ask all at once if unclear). Default mode needs only points 2, 3 and 5:
- Module/domain name → ID prefix (`INV`, `PUR`, …) and ticket prefix (`WMS-BE`, …)
- New project (greenfield) or adding to an existing codebase (where is its path/repo)
- **One repo or several.** If the feature touches more than one repo (e.g. backend + web + mobile), read `references/multi-repo.md` (in this skill's folder) before continuing.
- Full mode only — BRD level: **lengkap** (BR→UAT, for cross-division features or ones needing formal sign-off/UAT), **ringkas** (US→AC→TECH + TC), or **tanpa BRD** (PRD is detailed enough; tickets are created directly from the PRD)
- Which stage to start from. If `<docs>/prd.md`, BRD documents, or `<docs>/tickets/` already exist, continue from the next stage — don't rewrite. If old tickets were made under different rules (e.g. split per layer), suggest `/noskill:tiket rapikan` first.
- **Project profile.** If `<docs>/project-profile.md` doesn't exist and the plan has more than 3 tickets, run skill `project-profile` first (once per project). Smaller plans: use it if present; if not, just continue and offer to create it at the end. If it exists, just use it; refresh only if a manifest/lockfile changed since the commit in its header or a command in the profile fails.
- **Working branch.** If the project is a git repo, create a new branch from the current branch before the first code is written: `feat/<prefix-atau-slug>` for features, `fix/<slug>` for bugs. All ticket commits go to this branch. Multi-repo: same branch name in every repo that has tickets. If the working tree isn't clean, ask the user first (commit, stash, or continue on the current branch). Add `.noskill-cache/` and `<docs>/activity.json` to `.git/info/exclude` (cache for fast typecheck/lint, and the Activity file below).

## Plan (default mode)

Replaces Stages 1–4. The plan is the ticket files — no PRD, BRD, or ADR.
1. Read the code related to the request (grep, open the files) so `File/Lokasi` contains real paths. Record what you find in the ticket's `## Catatan` section — reusable helpers (path + function name), patterns/files to use as examples, and existing test files — so the developer doesn't repeat the same search.
2. **Up to 3 tickets:** write them yourself. **More than 3:** call `task-planner` with the user's request verbatim, the Stage 0 answers, your notes from step 1, the ticket prefix, and the codebase path (or repo list) — no PRD/BRD. Either way, write each ticket following the Ticket Rules (Aturan Tiket) in `task-breakdown` — one per bug, per endpoint, or per feature; if both BE and FE change, one BE ticket with `## Kontrak API` plus one FE ticket with `integrates_with` — at `<docs>/tickets/<ID>.md` in `ticket-workflow` format: ID `FIX-NNN` for a bug or `TASK-NNN` for a small feature, or the module prefix from Stage 0 (continue existing numbering), `trace: —`, `complexity` and `layer` (see `ticket-workflow`), AC covering the positive **and** negative side (go through the AC checklist in `task-breakdown`: numeric/DB column limits, case-insensitive matching, empty input, exact error responses, upload/import, dates, access), `File/Lokasi`, and `Cara Verifikasi` as real commands.
3. If the requirement is ambiguous, ask first — don't guess the AC.
4. **Gate:** show the board (AC + File/Lokasi per ticket; Kontrak API for BE tickets with an FE counterpart) and ask for approval plus the run mode: **automatic** (keep going until all DONE or a HOLD occurs) or **per ticket** (stop and report after each ticket is DONE), and **sequential** or **parallel** (developer starts the next ticket while the previous one is in review — read `references/parallel.md` if chosen). Default: automatic, sequential. Once approved, go to Stage 5.
5. **Fresh session for the ticket loop.** Everything Stage 5 needs lives in files (tickets, reports, profile), and every orchestrator turn re-reads the whole conversation. With more than ~5 tickets (either mode): after the gate, tell the user once that Stage 5 is cheaper in a new session (`/clear`, then `/noskill:tiket lanjut`). Continue here if they prefer.

## Stage 5 — Ticket Loop

Parallel mode: `references/parallel.md`. Multi-repo: `references/multi-repo.md`. Read them only when applicable.

Pick tickets in the order given in `ticket-workflow` (BUG first, then TODO whose dependencies are DONE).

**No database or server in Stage 5.** Per-ticket tests and verification run without them: BE with mocked repositories and in-process endpoint tests (Jest + supertest, `httptest`, …), FE with the API mocked from the Kontrak API. Don't start an environment or create a test database here, and don't pass one to agents. Specs that truly need a real database (migration, DB constraint, raw query, transaction/locking) are written by the developer, listed in its report under "Dicek di Stage 6", and run once in Stage 6 together with the E2E suite.

For one ticket:

**Agent reports to file.** Every agent call includes its report path: `<docs>/reports/<ID>/dev-<n>.md`, or `review-<n>.md` (n = `rounds` + 1). The agent writes the full report there and answers you in at most 6 lines (verdict, summary, path). Don't read the full report unless needed (e.g. to compose HOLD questions) — just pass the path to the next agent.

1. **Develop** — set `IN_PROGRESS`, call the developer agent picked by the ticket's `layer` (`be` → `backend-developer`, `fe` → `frontend-developer`, otherwise `developer`) with the ticket path and report path. If the picked agent is not installed, use `developer`.
   - **Model:** ticket `complexity: simple` → call developer with model `sonnet`; `complex` or empty → session model. A `simple` ticket that has gone back to the developer twice (`rounds` = 2) is redone with the session model.
   - **Never pass `model` to `ticket-reviewer`, `task-planner`, or `brd-tracer`** — their own `model: sonnet` applies; overriding it with the session model multiplies the cost of the stages that run most often. If any agent fails with `model_not_found`, tell the user once that the Sonnet alias is not reachable (check `ANTHROPIC_DEFAULT_SONNET_MODEL` in their settings), then re-run that call with the session model.
   - **Revision (CHANGES_REQUESTED/BUG): continue the same developer.** Send the latest review report path (or the Stage 6 bug report) to the developer agent that worked the ticket before (SendMessage to its agent ID — keep that ID for the session), not a new agent, since it already has the ticket and code context. Call a new developer only if the old agent is unavailable (new session, after HOLD, or model change).
   - `READY_FOR_REVIEW` → set `REVIEW`
   - `BLOCKED` → set `HOLD`
2. **Review + verification** — call agent `ticket-reviewer` with the ticket path, the latest developer report path (contains RED evidence and gates), and the review report path. The reviewer also runs the ticket's DB-free tests and Cara Verifikasi — there is no separate QA step.
   - `APPROVED` → set `DONE`, tick the AC in the ticket file, then `git commit` the changes on the working branch with message `<ID>: <title>` (local commit, no push; skip if not a git repo or the user said not to commit).
   - `CHANGES_REQUESTED` → set `IN_PROGRESS`, `rounds + 1`, write a findings summary (1–3 lines) and the review report path in Riwayat, back to step 1
   - `BLOCKED` → set `HOLD`
   - Bugs outside this ticket named by the reviewer → new `BUG-NNN` ticket per `ticket-workflow`
3. **`rounds` = 3** → set `HOLD` with a summary of why it keeps failing.

On every status change: update `status` in the frontmatter and add one line to `## Riwayat` (format `YYYY-MM-DD HH:MM FROM → TO (catatan)`) in the same edit, **before** calling the agent of the new stage (set `REVIEW` before calling `ticket-reviewer`) — never batch several changes at the end — so the board and `/noskill:kantor` show the stage that is actually running. Use date **and time** (`date '+%Y-%m-%d %H:%M'`), so `/noskill:tiket board` can compute each stage's duration. When the line closes an agent's stage and the Agent tool result shows its usage (e.g. `45.2k tokens · 3m 10s`), end the line with `(45.2k token, 3m)` so `/noskill:kantor` can show tokens per agent and per ticket; skip it when no usage is shown. Do the status edit, the Riwayat line, and the `activity.json` write in **one** Bash call per transition. Report to the user one line per change (`WMS-BE-004: REVIEW → DONE`), not long narration. When calling an agent, send the ticket path and the paths that stage needs: latest review report path for the developer, latest developer report path for the reviewer. Don't send file or report contents — agents read files themselves. Every agent call also includes `Waktu sekarang: <date '+%Y-%m-%d %H:%M %z'>`, so agents without Bash can timestamp what they write correctly (never write a placeholder such as `00:00`).

**HOLD:** don't stop the whole flow just because one ticket is HOLD. Continue other tickets that don't depend on it. Once no ticket can run, show all HOLD tickets at once with their questions to the user (they can also answer from `/noskill:kantor`; `/noskill:tiket lanjut` picks those answers up). After they answer, record the answer in Riwayat, return the ticket to its pre-HOLD status, reset `rounds` to 0 if the requirement changed, and continue the loop.

## Stage 6 — Finish

When all tickets are DONE (or the rest are HOLD awaiting the user):
- Show the final board.
- **Check everything once here.** During the ticket loop, tests and gates ran only for what tickets touched, without a database or server. At this stage, on the working branch (multi-repo: in every repo with tickets): run typecheck, lint, and the full DB-free test suite; then, if the project has integration specs or an E2E suite (including the "Dicek di Stage 6" specs from developer reports), start the profile's `Jalankan environment` / test database once in the background, apply migrations, wait for `Health check`, run those suites once, and stop/drop everything afterwards. If the profile doesn't record those commands, find them (README, docker-compose, package scripts) or ask the user, and record them in the profile. Never hand environment setup to an agent. Show a summary. If anything fails, find the causing ticket (`git log` per file), create a `BUG-NNN` ticket with `related` to it, and run it through the Stage 5 loop before continuing.
- **Final review (full mode, or more than 3 tickets).** Per-ticket reviews can't see cross-ticket problems, so after the checks pass call agent `cto` mode `SIGN_OFF` once with the working branch, its base branch, the ticket folder, the ADR folder, the check results, and report path `<docs>/reports/_cto/signoff-<n>.md`.
  - `SIGN_OFF` → continue.
  - `CONCERNS` → each bug item becomes a `BUG-NNN` ticket (`related` to the named ticket) and goes through the Stage 5 loop; each decision item is asked to the user. Then call `cto` `SIGN_OFF` once more. After a second `CONCERNS`, show the remaining items to the user and let them decide.
- Ask the user what to do with the working branch: **push + create PR**, **merge into the source branch locally**, or **leave it for now**. Don't push or merge without the user's answer.
- **If the user chooses push + PR:** push the working branch, then create the PR via the available GitHub tool (GitHub connector or `gh`). Build the PR description from the ticket files, not from scratch:
  ```markdown
  ## Ringkasan
  <1–3 kalimat: apa yang berubah dan kenapa>

  ## Tiket
  | ID | Judul | AC | Rounds |
  |---|---|---|---|
  | FIX-001 | ... | 4/4 ✓ | 1 |

  ## Verifikasi
  - <command test suite penuh> → <jumlah pass/fail>
  - <typecheck/lint kalau ada>

  ## Catatan
  - <keputusan dari HOLD, temuan di luar scope, hal yang belum dicek>
  ```
  If no GitHub tool is available, show that PR description so the user can paste it.
  **Multi-repo:** one PR per repo, containing only that repo's tickets. Create PRs in dependency order (provider first, e.g. `api` before `web`), then add a `## PR terkait` section with links to the other repos' PRs in every PR and state the merge order.
- Offer `user-guide` (end-user documentation) and `standup-update` (progress summary from ticket Riwayat) — both in plugin `noskill-extras`, if installed.

## Tracker Sync (optional)

If `<docs>/project-profile.md` contains `tracker: github` or `tracker: notion`, read `references/tracker-sync.md` and mirror tickets as described there.

## Rules

- **Don't skip a stage without its gate.** Default mode: the user approves the ticket list before code is written. Full mode: the user also approves the PRD and BRD (and sees the CTO's ADRs).
- **You don't write code yourself in Stage 5** — that's the developer agents' job. You don't judge code yourself — that's `ticket-reviewer`. Your role is moving tickets based on verdicts.
- **If agents are unavailable** (e.g. on Claude.ai), do that stage yourself in this session following the same skills the agent uses (`prd-writer`, `erp-requirements`, `task-breakdown`, `ticket-implementation`, `coding-standards`, `debug-assistant`; for the CTO stages, the checks listed in agent `cto`), but still run review + verification as a separate step with an explicit verdict.
- If the user asks for just one stage ("PRD aja", "tiketnya aja"), run only that stage and then ask whether to continue.
