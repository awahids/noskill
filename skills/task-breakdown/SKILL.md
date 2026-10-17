---
name: task-breakdown
description: >-
  Breaks a PRD or BRD into actionable tasks per phase with dependencies, acceptance criteria, verification steps, and a Trace column to US/AC/TECH, fitted to the existing codebase. Use for "pecah jadi task", "breakdown PRD", or a backlog from a PRD.
---

# PRD to Task Breakdown

Turns a PRD into a task list ready for a tracker (Notion/Jira/Trello/GitHub Issues) or for direct work. Unlike `prd-writer` (requirement document), this skill focuses on **execution**: what to do, in what order, and which people/systems are affected.

## Step 1: Understand the Project Context

**Before creating tasks, determine:**

1. **Pure new project (greenfield)** or **integration/addition to an existing project**? Check the PRD's Architecture section — if it mentions other running systems (existing repo, stack that must match, existing endpoints), it's an integration case.
2. If **integrating into an existing project**, tasks **must follow the folder structure, code patterns, and conventions the PRD names as existing** — not a "set up a new project from scratch" task. Quote the concrete paths/files the PRD names (e.g. `server/internal/delivery/handlers/canteen_proxy.handler.go`, the `stores/attendance.js` pattern) as direct references in the task, not generic folders like `src/handlers/`.
3. If the PRD doesn't detail the existing structure but says "integrated with system X", **ask the user** whether there is access to that existing codebase (local path, repo) so tasks are precise — don't guess an unmentioned folder structure.
4. **Check whether a BRD document (`erp-requirements` Part B) already exists** (US-xxx, AC-xxx, TECH-xxx) for this feature. If so, it is the primary source for the breakdown — see the traceability rules in Step 4. If not, the source is the PRD only.
5. Identify **how many systems/codebases are affected** (e.g. 2 — backend/frontend of the new Kantin system, plus a thin addition to the existing HRIS backend/frontend). Each affected system gets a separate task group; if that system is a separate repo, its tickets get a `repo:` field (see `feature-flow` Multi-Repo section).

## Ticket Rules (Aturan Tiket) — One Ticket per Endpoint, per Feature, or per Bug

The rule is deliberately simple so the ticket count is predictable:

| Change type | One ticket per | Ticket contents |
|---|---|---|
| **Backend (BE)** | one new or changed endpoint | the migration/entity that endpoint needs, DTO, service, controller, validation, test, Swagger, and the **API Contract (Kontrak API)** |
| **Frontend (FE)** | one feature/page | components, state, API calls, test |
| **Bug fix** | one bug | the fix and a test proving that bug doesn't come back. If the bug is in both BE and FE, make two tickets using the BE–FE rules below |
| **Feature without an endpoint** (job, scheduler, internal logic change) | one feature | the logic and its test |

- No tickets per layer or per file: migration, DTO, test, Swagger, or seeder go into the endpoint/feature ticket that needs them. A migration used by several endpoints goes into the first endpoint ticket that needs it; other tickets `depends_on` it.
- Several very small endpoints for the same resource (e.g. list + detail with no special logic) may be one feature ticket.
- Ticket count follows the number of endpoints, pages, and bugs — no more. If the result is more than 8 for one feature, re-check for per-layer tickets that should be merged.

### BE and FE: contract first, work together, QA together

1. **The API Contract (Kontrak API) is written when the ticket is created**, in the BE ticket's `## Kontrak API` section: method + path, request (body/query + validation rules), success response (status + JSON shape), and error responses (status + error code). This contract is the single reference for both sides.
2. An FE ticket that uses that endpoint fills `integrates_with: [<ID tiket BE>]` (not `depends_on`) and refers to the contract. This lets the FE developer start alongside BE, using the contract as reference (types/mocks from the contract), without waiting for BE to finish.
3. The BE ticket is still picked up first. The FE ticket may run concurrently (parallel mode) or afterwards (sequential mode).
4. **QA of the FE ticket waits until all tickets in `integrates_with` are DONE**, then tests FE and BE together: FE calls the real BE on the working branch, including the contract's negative scenarios (validation failure, not found, unauthorized).
5. The contract is never changed silently. If during work the contract must change, the developer reports `BLOCKED` and the orchestrator updates the contract in the BE ticket and records it in both tickets' Riwayat.

## Step 2: Extract Tasks from Each PRD Section

| PRD section | Becomes task type |
|---|---|
| Database Schema | Migration goes into the first endpoint/feature ticket that uses that table, not its own ticket |
| Core Features | BE: one ticket per endpoint (with Kontrak API). FE: one ticket per feature/page with `integrates_with` to its BE ticket |
| Architecture — proxy/integration | Separate integration-specific task (see Step 3) |
| API Design | Source of the Kontrak API in BE tickets. One ticket per endpoint |
| User Flow (conditional branches) | Added as ACs in the related feature ticket. Own ticket only for processes that run separately (scheduler job, automatic cut-off) — often missed if you only break down Core Features |
| Design & Technical Constraints | Initial setup tasks (project scaffolding, CI/CD, environment config) — only for new projects, skip for existing projects |

## Step 3: Integration Tasks — Precise, Not Generic

This is the part most often done wrong: **integration tasks into an existing system must be scoped as tightly as the PRD states**, not widened into duplicated business logic.

Principles (apply when the PRD describes a "thin proxy" pattern or similar):
- If the PRD says the existing side only adds a **thin proxy layer** (auth + forward, no business logic), the task is only that — don't create tasks that reimplement logic already in the new system
- Name the **existing roles/middleware being reused** (e.g. "role `employee`/`hr`/`administrator` already exists in `models.UserRole`, no new role needed") as a note in the task, so the developer doesn't invent unnecessary new structures
- If there is a **mechanism that doesn't exist yet and must be built** (PRD example: service-to-service auth doesn't exist in the existing system), it becomes its own task clearly marked as a **new addition to the existing system**, not part of the new system
- Data sync tasks (if any, e.g. a cross-system identity cache) are separate from plain CRUD tasks, because they usually need special consideration (sync schedule, what may/may not be overwritten — check the "Keterangan" column in the PRD's Database Schema for such rules)

## Step 4: Output Structure

Group tasks by **phase** (logical work order, not just per module), then by **system/layer** within that phase. Format:

```markdown
## Fase 1: [Nama Fase — misal "Database & Core Backend"]

### Backend — [Nama Sistem, misal "Kantin (baru)"]
- [ ] **[TASK-ID]** [Judul task singkat, actionable]
  - **Deskripsi:** [apa yang dikerjakan, 1-2 kalimat]
  - **Acuan PRD:** [section/bagian PRD terkait, misal "Database Schema — tabel orders"]
  - **Trace:** [hanya kalau ada dokumen BRD (`erp-requirements` Bagian B) — `US-INV-001 / TECH-003 / AC-002` yang dipenuhi task ini]
  - **File/lokasi:** [path konkret kalau project existing, atau struktur folder yang berlaku dari `coding-standards`]
  - **Acceptance Criteria:**
    - [ ] [kriteria terverifikasi 1]
    - [ ] [kriteria terverifikasi 2]
  - **Cara Verifikasi:** [langkah/command konkret untuk membuktikan task ini benar-benar selesai — bukan cuma "sudah dikerjakan". Contoh: "jalankan `go test ./internal/usecase/order/...`, semua lulus" atau "curl endpoint dengan payload X, cek response match skema Y" atau "buka halaman Z, submit form, cek data masuk ke tabel yang benar". Task tanpa cara verifikasi yang jelas biasanya berarti task-nya masih terlalu kabur — pecah lagi]
  - **Dependency:** [task lain yang harus selesai duluan, kalau ada — "Tidak ada" kalau tidak ada]
  - **Estimasi:** [S/M/L atau story point, opsional — hanya isi kalau user minta]

### Backend — [Nama Sistem Existing, misal "HRIS (existing, penambahan)"]
- [ ] **[TASK-ID]** [...]
```

**Task-ID numbering rule:** prefix per system/module so it's easy to track, e.g. `KTN-BE-001` (Kantin Backend), `KTN-FE-001` (Kantin Frontend), `HR-INT-001` (integration in HRIS) — consistent and short.

**Traceability to the BRD document (`erp-requirements` Part B, if the document exists):**
- Every TECH-xxx is covered by **at least one** task; several small TECHs for the same behavior may be merged into one task (the Trace column lists all of them). A TECH that is too large may be split into several tasks, but all refer to the same TECH in the **Trace** column — don't recreate tasks from the PRD for things already covered by a TECH.
- Task Acceptance Criteria come from the AC-xxx referenced by that TECH (write the ID, e.g. `AC-002: qty > outstanding ditolak`), not rewritten in new words.
- Extra tasks not derived from any TECH (setup, CI/CD, existing integration) are still allowed, but the Trace column is `—` with the reason in Deskripsi.
- After the task list is done, include a short table at the end so the BR→…→TECH→Task chain isn't broken:

```markdown
| TECH | Task-ID | AC yang dipenuhi | Test Case |
|---|---|---|---|
| US-INV-001 / TECH-003 | WMS-BE-004 | AC-002 | TC-INV-002 |
```

Re-check before finishing: every TECH has ≥1 task, and every AC appears in at least one task. If anything is missing, tell the user.

## Step 5: Sensible Phase Order

Default order (adjust if the PRD has different needs):
1. **Database & migration** — the foundation, all other tasks depend on it
2. **Backend core** — main business logic before endpoints
3. **API endpoints** — after the logic exists
4. **Integration with existing systems** (proxy, sync endpoint) — after the main API is stable, so you don't integrate against a still-changing API
5. **Frontend** — can run parallel with integration if different people, but order it after the basic API exists
6. **Supporting features** (notifications, analytics, report export) — usually can come later, not blocking core features
7. **QA/testing & documentation** — including `user-guide` if needed (Swagger docs go in the endpoint's ticket, not a separate task)

Mark which tasks **can run in parallel** vs which are **strictly sequential** via the Dependency column, so when a team/several people work on it it's clear what can start at the same time.

## Step 6: After the Task List Is Done

- Offer to push to a tracker if relevant (e.g. the user uses Notion for project management) — first check whether a connector is available before suggesting it; don't assume a specific tool without confirmation
- Save the task list as a Markdown file via the file-creation tool available in this environment, so it can be stored/shared, unless the user wants it pushed straight to another tool

## Principles

1. **One ticket per endpoint, per feature, or per bug** — see the Ticket Rules (Aturan Tiket) section above.
2. **Every task traces back to the PRD.** The "Acuan PRD" field isn't a formality — if a task can't be linked to any PRD section, question whether it's needed or is scope creep.
3. **Don't create tasks that duplicate logic across systems.** If system A (new) and system B (existing) are both touched by one feature, business logic lives in only one place (per the PRD's Architecture decision) — the other system gets only an integration/proxy task.
4. **Be realistic about what already exists.** Don't suggest "rebuild the folder structure" or a "big refactor" unless the PRD asks for it — integration tasks adapt to the existing project, not the other way around, unless the user explicitly asks for a refactor.
5. **"Done" is proven via Cara Verifikasi, not claimed.** A task is checked off only after the steps in "Cara Verifikasi" are actually run and the result matches — not because the code "looks right".
6. **Refactor tasks need a plan before becoming a normal task list.** If any task is a big refactor (not just adding a feature), don't break it down like a normal feature task — its first task is "draft the refactor plan" (see `coding-standards` section 1, principle 6) as its own deliverable; the execution tasks follow that plan after it's reviewed.

## Related Skills
- `prd-writer` — source PRD for the breakdown
- `erp-requirements` — if a BRD document (Part B) exists, the source of US/AC/TECH that must be referenced in the Trace column
- `coding-standards` — used for backend/frontend folder structure/conventions in new projects (no existing pattern to follow)
- `standup-update` — after tasks are worked on, progress can be summarized with this skill
