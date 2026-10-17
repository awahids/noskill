---
name: feature-flow
description: >-
  Engineering-team workflow: ticket → developer → reviewer → QA → DONE, with BUG/HOLD and a branch per feature. Quick mode for small fixes; full mode PRD → BRD → tickets. Use for "kerjakan sampai done", "lewat review dan QA", or resuming a board.
---

# Feature Flow

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

Write everything the user reads (answers, tickets, Riwayat, PR descriptions, documents) in Bahasa Indonesia unless the user writes in another language.

You are the orchestrator (tech lead + scrum master). You talk to the user, run the stages below in order, and are **the only one who moves ticket status** (see skill `ticket-workflow`). Agents do the heavy work; you pass context through files in `<docs>/`.

```
Stage 1-2 (interactive, this session)   Stage 3-4 (agent)                 Stage 5 (loop per ticket, agent)
erp-requirements A → prd-writer ──► brd-tracer ──► task-planner ──► developer → ticket-reviewer → qa-tester
     <docs>/prd.md                    <docs>/01..05      <docs>/tickets/      └── BUG / HOLD / revisi ◄──┘
```

## Choose a Mode

| Mode | When | Stages run |
|---|---|---|
| **Quick** | Bug fix, small feature, or **revision of an existing feature**: business rules are already clear and there is no new business process | Stage 0 → Quick Mode → Stage 5 → Stage 6 |
| **Full** | New feature, new module, cross-division, or needs requirement documents | Stages 0 → 6, all |

If unsure, state the mode you chose and why, and let the user correct it. Very small changes (typo, one config line) don't need `feature-flow` at all — just do them.

## Stage 0 — Context

Before starting, make sure you know the following (ask all at once if unclear). Quick mode needs only points 2 and 5:
- Module/domain name → ID prefix (`INV`, `PUR`, …) and ticket prefix (`WMS-BE`, …)
- New project (greenfield) or adding to an existing codebase (where is its path/repo)
- **One repo or several.** If the feature touches more than one repo (e.g. backend + web + mobile), see the Multi-Repo section.
- BRD level: **lengkap** (BR→UAT, for cross-division features or ones needing formal sign-off/UAT), **ringkas** (US→AC→TECH + TC), or **tanpa BRD** (PRD is detailed enough; tickets are created directly from the PRD)
- Which stage to start from. If `<docs>/prd.md`, BRD documents, or `<docs>/tickets/` already exist, continue from the next stage — don't rewrite. If old tickets were made under different rules (e.g. split per layer), suggest `/noskill:tiket rapikan` first.
- **Project profile.** Full mode: if `<docs>/project-profile.md` doesn't exist, run skill `project-profile` first (once per project). Quick mode: use it if present; if not, just continue and offer to create it at the end. If it exists, just use it; refresh only if a manifest/lockfile changed since the commit in its header or a command in the profile fails.
- **Working branch.** If the project is a git repo, create a new branch from the current branch before the first code is written: `feat/<prefix-atau-slug>` for features, `fix/<slug>` for bugs. All ticket commits go to this branch. Multi-repo: same branch name in every repo that has tickets. If the working tree isn't clean, ask the user first (commit, stash, or continue on the current branch). Add `.noskill-cache/` to `.git/info/exclude` (cache for fast typecheck/lint).

## Quick Mode — One Ticket Directly

Replaces Stages 1–4 for small changes:
1. Read the code related to the request (grep, open the files) so `File/Lokasi` contains real paths. Record what you find in the ticket's `## Catatan` section — reusable helpers (path + function name), patterns/files to use as examples, and existing test files — so the developer doesn't repeat the same search.
2. Write the ticket following the Ticket Rules (Aturan Tiket) in `task-breakdown` — one per bug, per endpoint, or per feature; if both BE and FE change, one BE ticket with `## Kontrak API` plus one FE ticket with `integrates_with` — at `<docs>/tickets/<ID>.md` in `ticket-workflow` format: ID `FIX-NNN` for a bug or `TASK-NNN` for a small feature (continue existing numbering), `trace: —`, `complexity` (see `ticket-workflow`), AC covering the positive **and** negative side, `File/Lokasi`, and `Cara Verifikasi` as real commands.
3. If the requirement is ambiguous, ask first — don't guess the AC.
4. **Gate:** show the ticket (AC + File/Lokasi) and ask for brief approval. Once approved, go to Stage 5.

## Stage 1 — Domain Design (ERP/WMS only)

Run the checklist of skill `erp-requirements` Part A (domain design) in this session. Skip for non-ERP features.

## Stage 2 — PRD

Run skill `prd-writer` **in this session** (not in an agent), because it must ask at least 5 clarifying questions and wait for the user's answers. Save to `<docs>/prd.md`.

**Gate:** ask the user to approve the PRD before continuing.

## Stage 3 — BRD Traceability

**Skip this stage if level = tanpa BRD**; go straight to Stage 4.

Call agent `brd-tracer` with: PRD path, domain prefix, level (full/ringkas), and the Stage 0 context answers. Output goes to `<docs>/01-business/` … `<docs>/05-testing/`.

If the agent returns a list of open questions, ask the user, then call it again with the answers.

**Gate:** show a summary (count of BR/US/AC/TECH/TC) and ask for user approval.

## Stage 4 — Tickets

Call agent `task-planner` with: PRD path, BRD folder (or the note "tanpa BRD"), ticket prefix, and codebase path (multi-repo: the `## Repo` table from the profile). Output is ticket files `<docs>/tickets/<ID>.md` with status `TODO`.

**Gate:** show the board (see `ticket-workflow` Board section) and ask for approval. If there are per-layer tickets (separate migration/DTO/test), merge them before starting. For BE tickets with an FE counterpart, also show their Kontrak API — the contract is approved together with the ticket list. Also ask the run mode: **automatic** (keep going until all DONE or a HOLD occurs) or **per ticket** (stop and report after each ticket is DONE), and **sequential** or **parallel** (developer starts the next ticket while the previous one is in review/QA — see Parallel Mode). Default: automatic, sequential.

## Stage 5 — Ticket Loop

Pick tickets in the order given in `ticket-workflow` (BUG first, then TODO whose dependencies are DONE).

**Environment once per session.** If any ticket needs a running server/database for QA (especially FE tickets with `integrates_with`), before the first QA start the environment once with the profile's `Jalankan environment` command (multi-repo: from the BE repo's working branch) as a background process, then wait until the `Health check` command succeeds. Give its URL to every QA; QA does not start or stop the server itself. If the server doesn't use watch mode, restart it after a BE ticket is merged into the working branch. Stop it at the end of Stage 6. If the profile doesn't record those commands yet, find them yourself (README, docker-compose, package scripts) or ask the user, start the environment, and record the commands in the profile. Never hand environment setup to QA.

For one ticket:

**Agent reports to file.** Every agent call includes its report path: `<docs>/reports/<ID>/dev-<n>.md`, `review-<n>.md`, or `qa-<n>.md` (n = `rounds` + 1). The agent writes the full report there and answers you in at most 6 lines (verdict, summary, path). Don't read the full report unless needed (e.g. to compose HOLD questions) — just pass the path to the next agent.

1. **Develop** — set `IN_PROGRESS`, call agent `developer` with the ticket path and report path.
   - **Model:** ticket `complexity: simple` → call developer with model `sonnet`; `complex` or empty → session model. A `simple` ticket that has gone back to the developer twice (`rounds` = 2) is redone with the session model.
   - **Revision (CHANGES_REQUESTED/BUG): continue the same developer.** Send the latest review/QA report path to the developer agent that worked the ticket before (SendMessage to its agent ID — keep that ID for the session), not a new agent, since it already has the ticket and code context. Call a new developer only if the old agent is unavailable (new session, after HOLD, or model change).
   - `READY_FOR_REVIEW` → set `REVIEW`
   - `BLOCKED` → set `HOLD`
2. **Review** — call agent `ticket-reviewer` with the ticket path, the latest developer report path (contains RED evidence and gates), and the review report path.
   - `APPROVED` → set `QA`
   - `CHANGES_REQUESTED` → set `IN_PROGRESS`, `rounds + 1`, write a findings summary (1–3 lines) and the review report path in Riwayat, back to step 1
   - `BLOCKED` → set `HOLD`
3. **QA** — call agent `qa-tester` with the ticket path, QA report path, and folder `<docs>/05-testing/` (absent if tanpa BRD — QA tests directly against the ticket's AC). Tickets with `integrates_with` (FE) go to QA only after all BE tickets in that list are DONE; until then the ticket stays `QA` with Riwayat "menunggu <ID BE>", and QA tests it together with the BE (FE calls the real BE). Pass the environment URL to QA whenever the ticket needs a running server.
   - `PASS` → set `DONE`, tick the AC in the ticket file, then `git commit` the changes on the working branch with message `<ID>: <title>` (local commit, no push; skip if not a git repo or the user said not to commit)
   - `FAIL` → set `BUG`, `rounds + 1`, write a bug summary (1–3 lines) and the QA report path in Riwayat, back to step 1
   - `BLOCKED` → set `HOLD` — except `BLOCKED: environment belum jalan`: start or fix the environment yourself once, then re-run QA (not counted as a round)
   - If QA reports a bug outside this ticket, create a new `BUG-NNN` ticket per `ticket-workflow`
4. **`rounds` = 3** → set `HOLD` with a summary of why it keeps failing.

On every status change: update `status` in the frontmatter and add one line to `## Riwayat` with date **and time** (`date '+%Y-%m-%d %H:%M'`), so `/noskill:tiket board` can compute each stage's duration. Report to the user one line per change (`WMS-BE-004: REVIEW → QA`), not long narration. When calling an agent, send the ticket path and the paths that stage needs: latest review/QA report path for the developer, latest developer report path for the reviewer. Don't send file or report contents — agents read files themselves.

### Parallel Mode (pipeline)

Like a real team: while ticket A is in review or QA, the developer is already working on ticket B. Git repos only.

1. **Tickets that may run concurrently:** all their `depends_on` are DONE (`integrates_with` doesn't block — an FE ticket may be worked alongside its BE ticket based on the Kontrak API), their `File/Lokasi` doesn't overlap with another active ticket, and the ticket doesn't change dependencies/lockfile. Otherwise the ticket waits. Max 2 active tickets at once; **3 if the active tickets are in different repos** (e.g. a BE–FE pair in `api` and `web`, which can't conflict on files). The user may ask for more (max 4).
2. **Worktree per ticket:** before the developer starts, run `git worktree add .worktrees/<ID> -b ticket/<ID> <branch kerja>` and add `.worktrees/` to `.git/info/exclude`. If the project has uncommitted dependency folders (`node_modules`, `vendor`), symlink them inside the worktree so tests run without reinstalling.
3. **Send the working directory to agents:** every developer, reviewer, and QA call includes that ticket's worktree path. Ticket files stay in `<docs>/tickets/` in the main checkout, and only you write them.
4. **Run agents in the background** and process verdicts in the order they finish. As soon as the developer reports `READY_FOR_REVIEW` for ticket A, call the reviewer for A and at the same time the developer for the next eligible ticket.
5. **On PASS:** commit in the worktree (`<ID>: <title>`), then in the main checkout `git merge --no-ff ticket/<ID>` into the working branch. Then remove the ticket's worktree and branch, and commit the ticket file update.
   - **If the merge conflicts:** `git merge --abort`, set the ticket to `IN_PROGRESS` with the note "gabungkan branch kerja terbaru ke ticket/<ID> dan selesaikan konflik", and the ticket goes through review and QA again.
6. Total tokens are about the same as sequential mode since the work is the same; what shrinks is waiting time.

### Multi-Repo

For one feature touching several repos (e.g. `api` NestJS, `web` Vue, `mobile` Flutter).

1. **Docs repo:** the repo this session runs in. PRD, BRD, and all tickets live only in this repo's `<docs>/` — one board for the whole feature. Other repos get no noskill folder.
2. **Repo list** is in the `## Repo` section of `<docs>/project-profile.md`: short name, path relative to the docs repo, and its profile file. Other repos' profiles are stored in the docs repo as `<docs>/project-profile-<nama>.md` (run `project-profile` for that repo). If a repo path doesn't exist on this machine, ask the user — don't guess.
3. **One ticket = one repo.** A ticket has field `repo: <nama>` and `File/Lokasi` relative to that repo's root. A change needing two repos is split into two tickets: the `api` ticket holds the Kontrak API, and the `web` ticket sets `integrates_with` to that `api` ticket — worked concurrently, QA'd together after the `api` ticket is DONE.
4. **Working branch** with the same name is created in every repo that has tickets, before the first ticket in that repo is worked.
5. **When calling agents**, send working directory = that ticket's repo path (or its worktree in parallel mode, created with `git -C <path repo> worktree add …`) and that repo's profile path. The ticket path stays in the docs repo.
6. **Commit code** in the ticket's repo (`<ID>: <title>`). Ticket file updates are committed in the docs repo.
7. **Cross-repo QA:** a `web` ticket is tested after its paired `api` ticket is DONE, against the environment you started from the `api` repo's working branch that already contains that ticket. If it can't run here, set `HOLD` with an explanation.
8. Tickets in different repos never overlap `File/Lokasi`, so in parallel mode they can run concurrently as long as `depends_on` is met — including BE–FE pairs via `integrates_with`.

**HOLD:** don't stop the whole flow just because one ticket is HOLD. Continue other tickets that don't depend on it. Once no ticket can run, show all HOLD tickets at once with their questions to the user. After they answer, record the answer in Riwayat, return the ticket to its pre-HOLD status, reset `rounds` to 0 if the requirement changed, and continue the loop.

## Stage 6 — Finish

When all tickets are DONE (or the rest are HOLD awaiting the user):
- Show the final board.
- Stop the environment started in Stage 5 after the checks below finish.
- **Check everything once here.** During the ticket loop, tests and gates run only for what tickets touched. At this stage run typecheck, lint, the full test suite, and the E2E suite if the project has one, on the working branch (multi-repo: in every repo with tickets), then show a summary. If anything fails, find the causing ticket (`git log` per file), create a `BUG-NNN` ticket with `related` to it, and run it through the Stage 5 loop before continuing.
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

If `<docs>/project-profile.md` contains `tracker: github` or `tracker: notion`, the ticket board is copied to that tracker. One-way: ticket files remain the source of truth; the tracker is only a mirror.
- **When:** when a ticket is created (Stage 4 or Quick Mode), and when a ticket becomes DONE, BUG, or HOLD. Other status changes aren't synced, to save tool calls.
- **GitHub Issues:** one issue per ticket. Title `<ID>: <title>`, body contains the AC, label `noskill:<status>`. Issue is closed on DONE.
- **Notion:** one row per ticket in database `notion_database` (columns ID, Judul, Status). Look up an existing row by ID before creating a new one.
- Store the issue number or page URL in the ticket frontmatter (`tracker_ref:`) so later updates don't create duplicates.
- If the tracker tool is unavailable or fails, continue the flow and mention it once to the user. Sync must never stop the work.

## Rules

- **Don't skip a stage without its gate.** Full mode: the user approves the PRD, BRD, and ticket list before code is written. Quick mode: the user approves the ticket.
- **You don't write code yourself in Stage 5** — that's `developer`'s job. You don't judge code yourself — that's `ticket-reviewer` and `qa-tester`. Your role is moving tickets based on verdicts.
- **If agents are unavailable** (e.g. on Claude.ai), do that stage yourself in this session following the same skills the agent uses (`erp-requirements`, `task-breakdown`, `coding-standards`, `debug-assistant`), but still run review and QA as separate steps with explicit verdicts.
- If the user asks for just one stage ("PRD aja", "tiketnya aja"), run only that stage and then ask whether to continue.
