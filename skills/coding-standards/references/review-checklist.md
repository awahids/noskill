# Code Review Checklist (section 9 of coding-standards)

Baca saat me-review kode (reviewer, CTO). Developer yang menulis kode tidak perlu memuatnya.

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
