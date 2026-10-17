---
name: coding-standards
description: >-
  Code standards for NestJS, Laravel, Go/Gin, Vue, Next.js, PostgreSQL/MySQL: naming, folders, ORM/migrations, API response format, state, TDD, quality gates, review checklist. Use for new code/migrations, code review, or "sesuai standar", "naming", "struktur folder".
---

# Coding Standards — Reference for Writing & Reviewing Code

This skill is the personal/team coding standard for: **NestJS, Laravel, Golang/Gin, Vue.js, Next.js, TypeScript, PHP, PostgreSQL/MySQL**.

Apply it EVERY TIME you:
- Write new code (function, class, component, endpoint, migration)
- Create a new file or folder
- Do a code review (use the checklist at the end as the reference)
- Design API/response structure

If the user's stack differs from what is covered here, still apply the **general principles** (sections 1 & 2.1) and adapt sensibly.

---

## 1. General Principles

1. Consistency beats personal preference — follow this standard even when another valid way exists.
2. Readability first — code is read far more often than it is written.
3. Explicit beats implicit — avoid "magic" that makes others guess.
4. **Reuse first; DRY but don't over-abstract.**
   - Before writing new logic, search the codebase (grep the related function/concept names). If a helper/service already does the same thing, use it — don't write a second version.
   - Put business logic in a reusable, testable layer (service/usecase/`lib`), not in controllers, handlers, or UI components. UI/controllers only call it.
   - Duplication twice is fine; extract a shared function on the 3rd. Don't build abstractions "to be reusable later" for code used only once.
5. Fail fast, fail loud — validate input up front; don't let errors spread silently.
6. **Large refactors need a plan first, not direct changes.** For refactors touching many files/changing structure (not a small rename or the simplify pass in 5.3), write a step-by-step plan before touching code: what changes, the order of steps, and how to verify each step doesn't break what already works. Unplanned refactors carry a high risk of fixing one thing while breaking something unnoticed — especially dangerous in logic already used in production. The plan can be short (bullet list) for small refactors, or more detailed (like the task breakdown in the `task-breakdown` skill) for large cross-module refactors.
7. **Surgical changes — touch only what was asked.** If the task is "fix bug X", don't also reformat the file, change the writing style, or "tidy up" surrounding code that wasn't requested — even if you judge it better. Unrequested changes make diffs hard to review (important changes drown among cosmetic ones) and risk changing unintended behavior. If you find surrounding code that is clearly problematic but out of the task's scope, **mention** it to the user as a separate note — don't change it unasked. The simplify pass (5.3) and planned refactors (point 6) are legitimate exceptions because that is their purpose, but still as their own explicit task, not riding along on another task.
8. **State assumptions explicitly; don't silently pick one.** If a requirement/instruction has more than one reasonable interpretation, state which one you used and why — don't proceed on one assumption without saying so. This differs from "always ask first": for things decidable with a reasonable assumption, proceed, but write the assumption explicitly (e.g. in a comment, the opening summary of the answer, or the PR description) so the user can correct it if wrong, instead of discovering it's wrong after the code has gone far.
9. **Simplest solution first.** Before writing code, think through the approach, then take the first option that fully solves the problem:
   1. Does it need to exist at all? Don't add features, options, or flexibility that weren't requested.
   2. Already in the codebase (helper, service, component, pattern)? Use it the same way the surrounding code does.
   3. In the standard library or a framework feature? Use that.
   4. In an already-installed dependency? Use that. Don't add a new dependency for a few lines of code.
   5. If it still must be written: the minimal correct code, with no abstractions, wrappers, config, or "for later" code not needed now.

   Simple does not mean sloppy: input validation at system boundaries, error handling that prevents data corruption, and security must not be cut. Between two equally simple solutions, pick the one that is correct for edge cases.

---

## 2. Naming Convention

### 2.1 General (all languages)

| Element | Convention | Example |
|---|---|---|
| Boolean | Prefix `is`, `has`, `can`, `should` | `isActive`, `hasPermission`, `canEdit` |
| Function/Method | Verb + object | `getUserById()`, `calculateTotalPrice()` |
| Event handler | Prefix `on` / `handle` | `onSubmit`, `handleClick` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Private/internal | Prefix `_` (if the language has no native `private`) | `_calculateInternal()` |

Avoid: generic names (`data`, `temp`, `obj`), unclear abbreviations (`usr`, `qty`), misleading names (a `getUser` function that also deletes data).

### 2.2–2.5 Per Stack & Database

**Read [`references/naming.md`](references/naming.md) before** creating a new file, class, struct, table, column, or migration: 2.2 TypeScript/JavaScript, 2.3 PHP, 2.4 Golang, 2.5 database (tables, columns, required columns, relations, indexes).

Always-applicable summary: tables are plural English snake_case (`order_items`), PK `id` of type UUID, FK `{tabel_singular}_id`, required columns `created_by`/`updated_by`/`created_at`/`updated_at`/`deleted_at`, and API response JSON fields are snake_case, identical to the database columns.

---

## 3. ORM & Database Access Standard (Node.js & Golang)

**Read [`references/orm.md`](references/orm.md) before** writing a schema/model, query, or migration. Contents: production migration discipline, Prisma v7+ (`prisma-client` generator, `prisma.config.ts`), TypeORM, when to choose Prisma vs TypeORM, GORM/sqlx for Golang, and Supabase.

Always-applicable summary: one ORM/query approach per service, the production schema changes only through committed migration files (not `db push`/`AutoMigrate()`/`synchronize: true`), and destructive changes are done in stages (nullable → backfill → constraint).

---

## 4. Folder Structure

**Read [`references/folder-structure.md`](references/folder-structure.md) before** creating a new project, a new module, or a file in a location not used before. Contents: 4.1 NestJS (modular by feature), 4.2 Laravel, 4.3 Vue.js, 4.4 Next.js App Router, 4.5 Golang layered structure.

If the project already has its own structure, follow the existing structure — the reference is for new projects.

---

## 5. Function & Method Standards

- Max ~30-40 lines per function. If longer, consider splitting.
- Single Responsibility — 1 function, 1 job. If the name needs "and" (`saveAndSendEmail`), consider splitting.
- Max 3-4 parameters — beyond that use an object/DTO.
- Explicit return type for public methods/services (TypeScript only).
- Error handling: no silent catch (empty `catch {}`). Use descriptive custom exceptions, handled in the filter/handler layer.

TypeScript examples and Golang error handling patterns (wrap errors, sentinel errors, `panic` only for programmer errors, handler maps errors to status codes): [`references/functions-tdd.md`](references/functions-tdd.md).

### 5.1 Test-Driven Development (TDD)

For logic with nontrivial business rules (calculations, branching validation, state machines like order status) — **write the test before the implementation**, not the other way round. For simple code (CRUD without special logic, passthrough), TDD may be skipped — use judgment, don't force it onto every line of code.

**RED → GREEN → REFACTOR cycle:**
1. **RED** — write a test for the desired behavior, run it, make sure it **fails** (if the test passes immediately without an implementation, it tests nothing — fix it first)
2. **GREEN** — write the **most minimal** code that makes the test pass; don't also add other features that have no test yet (YAGNI — *You Aren't Gonna Need It*)
3. **REFACTOR** — tidy the code once the test is green (naming, duplication, structure), rerun the tests after each refactor to make sure they still pass

Full cycle example with code: [`references/functions-tdd.md`](references/functions-tdd.md).

**Additional rules:**
- If you wrote the code first and then realize it needs a test, write the test and **make sure it can fail** when the logic is wrong (temporarily revert the implementation, confirm the test goes red, then restore) — a test never proven able to fail cannot be trusted
- Tests follow the folder structure in section 4 (co-locate `*.spec.ts`/`*_test.go` next to the file under test, or a `tests/` folder per framework convention)
- One test = one verified behavior — don't combine many unrelated assertions in one generically named test
- **Positive and negative tests are mandatory** for every business rule:
  - **Positive** — valid input produces the correct result (happy path)
  - **Negative** — invalid input / forbidden conditions are correctly rejected (correct error, data unchanged)
  - **Boundary** — the value exactly at the rule's boundary and one step beyond it (e.g. `= 90%` and `89,99%`), because bugs live there most often
  - Test names state their type so they are easy to check, e.g. `rejects quantity above outstanding` (negative) and `accepts quantity equal to outstanding` (boundary)

### 5.2 Quality Gates — Mandatory Order, Don't Skip Stages

Before code counts as "done", run these in order — **if a stage fails, stop and fix it at that stage; don't move on to the next one**:

```
1. Type check  →  2. Lint  →  3. Test  →  4. Review (manual/self-review)
```

**Mandatory anti-pattern to avoid — never "fix" a failing test by changing the test so it passes, unless the test is proven to be wrong** (not the implementation). If a test fails:
1. Read why it failed — is the implementation wrong, or the test's expectation?
2. If the implementation is wrong → fix the implementation, keep the test
3. If the test really is wrong (mistaken expectation) → it may be changed, but **explain why** (in the commit message or a comment); don't silently change it to go green fast

Anti-pattern example: [`references/functions-tdd.md`](references/functions-tdd.md).

### 5.3 Simplify Pass — After the Feature Works

Tidy code without changing behavior, after tests and quality gates are green; rerun the tests afterward. Details: [`references/functions-tdd.md`](references/functions-tdd.md).

### 5.4 Logging: Error Log vs Audit Log

Error logs (for debugging, short retention) and audit logs (who-changed-what for compliance, append-only, written in the service layer) are two different things — don't mix them. **Read [`references/logging.md`](references/logging.md) before** adding logging or an audit table: it has the full comparison, format, and rules for each log type.

---

## 6. API Design Standard

**Read [`references/api-design.md`](references/api-design.md) before** creating or changing an endpoint. Contents: 6.1 URL prefix & versioning, 6.2 response format (including the Golang/Gin implementation, which must match exactly), 6.3 endpoint naming, 6.4 HTTP status codes, 6.5 query parameters for multi-field filtering.

**Read [`references/api-doc.md`](references/api-doc.md) before** adding or changing an endpoint's Swagger/OpenAPI documentation. Contents: required decorators/annotations per endpoint for NestJS (`@nestjs/swagger`), Laravel (`l5-swagger`/`scramble`), and Golang (`swaggo`), standard response schema, versioning setup, breaking change checklist, and pre-merge checklist.

Always-applicable summary: every endpoint uses the `/api/v{n}` prefix, one identical response envelope format across all endpoints & versions, and `statusCode` in the body always equals the HTTP status.

---

## 7. Frontend: State Management Standard (Vue.js & Next.js)

**Read [`references/frontend.md`](references/frontend.md) before** writing a store, API service, or reusable component in Vue.js/Next.js. Contents: 7.2 3-layer structure (don't skip layers), 7.3 additional rules, 7.4 performance priorities, 7.5 composition pattern (avoid boolean prop hell).

---

## 8. Git & Commit Convention

Always-applicable summary: commits use Conventional Commits (`feat:`, `fix:`, `refactor:`, …), `.env` is never committed (commit `.env.example` instead), and secrets are not hardcoded. **Read [`references/git.md`](references/git.md)** for branch naming, secret rules and rotation, and changelog.

---

## 9. Code Review Checklist (use as the reference when reviewing)

**Naming & Structure**
- [ ] Variable/function/class names follow the conventions in section 2
- [ ] Files are placed in folders matching the structure in section 4
- [ ] No business logic stray in controllers/components

**Database**
- [ ] Table names plural snake_case, field names follow section 2.5
- [ ] Primary key uses UUID (not auto-increment integer), unless there is an explicit reason to deviate
- [ ] Tables whose data users can change have `created_by`/`updated_by` (nullable), not just `created_at`/`updated_at`
- [ ] FKs named `{singular_table}_id` and pointing to the correct table
- [ ] Indexes exist for FKs and frequently filtered columns
- [ ] Many-to-many relations via a pivot table, not an array/JSON column
- [ ] Migration is reversible (correct `down()`/rollback exists)
- [ ] If using Prisma: model fields **snake_case directly** (not camelCase + `@map`), only table names use `@@map`, no queries inside loops (N+1), multi-step transactions use `$transaction`
- [ ] If using TypeORM: entity fields **snake_case directly** (not camelCase + `@Column({ name })`), explicit `@Entity('nama_tabel')`, `synchronize: true` not used in production
- [ ] If using Golang (GORM/sqlx): struct fields PascalCase with `json`/`db`/`gorm:"column:"` snake_case tags consistent with each other, explicit `TableName()`, no `AutoMigrate()` in production, errors wrapped with `%w`, not swallowed (`_`)

**Consistency**
- [ ] Endpoints use the `/api/v{n}` prefix, no unversioned routes
- [ ] If there is a breaking change in response/behavior, the API version was bumped (not the old-version endpoint changed directly)
- [ ] **API response fields snake_case, identical to entity/database fields** — no camelCase transformation in controller/resource (section 6.2)
- [ ] If Golang: responses use the `response.Success`/`response.Error`/`response.SuccessWithPagination` helpers, not manual `gin.H{}` whose format can drift between handlers
- [ ] Filter query parameters use the same names as the database columns (section 6.5)
- [ ] Error handling follows the agreed pattern
- [ ] Endpoint naming follows REST conventions

**Frontend (Vue/Next.js)**
- [ ] No direct API calls in components/pages (inline fetch/axios) — must go through a store/query hook
- [ ] A separate API service layer exists, not URLs/endpoints written directly in the store/hook
- [ ] **No mapping/renaming of API fields in service/store** (e.g. `total_amount` silently turned into `totalAmount`) — fields used as-is
- [ ] Server state (API data) and client state (UI state) are separated, not mixed in one store
- [ ] Loading/error/empty states handled in the state management layer, not logic scattered across components
- [ ] If a performance issue was addressed, request waterfall/bundle size was checked first before adding `useMemo`/`computed` everywhere
- [ ] Shared/reusable components don't pile up too many boolean props — consider a compound component/explicit variants once there are >4-5 interrelated boolean props

**Change Scope**
- [ ] The PR/change touches only what the task asked — no unrequested reformat/cosmetic refactor riding along
- [ ] If an assumption was made because a requirement was ambiguous, it is stated explicitly (comment/PR description), not silently chosen

**Code Quality**
- [ ] Functions not too long/complex (>40 lines → suspect)
- [ ] No magic numbers/strings without a constant
- [ ] No duplicated code that should be reused
- [ ] No leftover `console.log`/`dd()`/`var_dump()` — use a structured logger per section 5.4
- [ ] No sensitive data (passwords, tokens, full personal data) logged
- [ ] Privileged actions that change important data (subsidies, system configuration, other users' data) are recorded in the audit log, not just the error log
- [ ] No hardcoded credentials/API keys/tokens
- [ ] If using Supabase and tables are accessed from the client: RLS enabled with explicit policies, not open by default
- [ ] `.env.example` is up to date if new env vars were added
- [ ] Nontrivial business logic (calculations, branching validation, state machines) has tests — not just "tried manually once"
- [ ] If a test was failing before, the cause was fixed in the implementation (not numbers/expectations in the test silently adjusted to pass)
- [ ] If this is a large refactor PR, a plan was followed (not ad-hoc changes midway without clear direction)
- [ ] Schema migrations are not destructive without a staged strategy (if they touch tables that already have production data)

Give feedback with labels: `[blocking]` (must fix), `[nit]` (optional), `[question]` (clarification).

---

## Notes

This is a living standard. If a decision deviates from it for a specific technical reason, document the reason in a code comment.
