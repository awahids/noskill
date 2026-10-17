# Coding Standards — Naming per Stack & Database

> Part of the `coding-standards` skill. Section numbers are kept so references like "section 2.5" stay valid.

### 2.2 TypeScript / JavaScript (NestJS, Next.js, Vue)

| Element | Convention | Example |
|---|---|---|
| Variable, function (internal logic) | camelCase | `userProfile`, `fetchOrderList()` |
| Class, Interface, Type | PascalCase | `UserService`, `OrderDto` |
| Interface | No `I` prefix | `User` not `IUser` |
| Enum | PascalCase (name) | `enum OrderStatus { Pending, Completed }` |
| File (NestJS) | kebab-case + type suffix | `user.service.ts`, `create-order.dto.ts` |
| File (Vue component) | PascalCase | `UserProfileCard.vue` |
| File (Next.js route) | kebab-case | `app/order-history/page.tsx` |
| Folder | kebab-case | `order-management/` |

> **IMPORTANT — Special rule for entity/DTO/API contract fields:** The camelCase rule above applies to variables and functions of **internal logic** (outside data flowing from/to the database). **Fields on Entity, DTO, Request/Response, and Model** **must be snake_case, exactly matching the database column name** (see section 2.5). This is deliberate: API and entity fields must be identical to column names so they can be used directly for multi-field queries and relation filters without a mapping/transformation layer.
>
> ```typescript
> // ✅ Entity/DTO — fields exactly match database columns
> export class Order {
>   id: string;
>   user_id: string;
>   order_code: string;
>   total_amount: number;
>   created_at: Date;
> }
>
> // ✅ Internal-logic function/variable — stays camelCase
> function calculateShippingFee(order: Order): number { ... }
> const isEligibleForDiscount = order.total_amount > 100000;
> ```
> Object literal/JSON fields that form the API contract (request body, response body, query params) are always snake_case. Function, class, and local variable names that don't directly represent DB data stay camelCase as usual.

### 2.3 PHP (Laravel)

| Element | Convention | Example |
|---|---|---|
| Class | PascalCase | `OrderService`, `UserController` |
| Method, variable (internal logic) | camelCase | `getActiveUsers()`, `$totalAmount` |
| Model/Resource/Request field (DB data) | snake_case, same as column | `$order->user_id`, `$order->total_amount` |
| File | Matches class name (PSR-4) | `OrderService.php` |
| Migration | snake_case + timestamp prefix | `2025_01_10_create_orders_table.php` |
| Config key | snake_case | `payment_gateway_url` |

> Laravel/Eloquent already uses snake_case for model attributes by default — so this rule is natural in Laravel with no extra adjustment. What to guard: don't convert API Resources (`toArray()`) to camelCase; return fields as-is per column name.

### 2.4 Golang (Gin/Fiber)

Go has its own casing rules that can't exactly match TypeScript/PHP — exported identifiers **must** start with a capital letter (a compiler rule, not style). So field parity with the database is achieved via **struct tags**, not the Go field name itself.

| Element | Convention | Example |
|---|---|---|
| Package name | lowercase, one word, no underscore | `package order`, `package handler` |
| Struct, Interface | PascalCase | `type OrderService struct`, `type OrderRepository interface` |
| Exported function/method | PascalCase | `func GetOrderByID(id string)` |
| Unexported function/variable (package-internal) | camelCase | `func calculateTotal(items []Item) int` |
| Struct field (exported, required for JSON/DB) | PascalCase field name + snake_case tag | `OrderID string \`json:"order_id" db:"order_id"\`` |
| File | snake_case | `order_service.go`, `order_repository.go` |
| Constant | PascalCase or UPPER_SNAKE_CASE (consistent per project) | `const MaxRetryCount = 3` |
| Error variable | `Err` prefix | `var ErrOrderNotFound = errors.New("order not found")` |

**Struct fields must use tags for field parity with database/API (continuing the section 2.2 rule):**
```go
type Order struct {
    ID          string     `json:"id" db:"id"`                   // UUID, see section 2.5
    UserID      string     `json:"user_id" db:"user_id"`
    OrderCode   string     `json:"order_code" db:"order_code"`
    Status      string     `json:"status" db:"status"`
    TotalAmount float64    `json:"total_amount" db:"total_amount"`
    CreatedBy   *string    `json:"created_by" db:"created_by"`     // nullable, pointer
    UpdatedBy   *string    `json:"updated_by" db:"updated_by"`     // nullable, pointer
    CreatedAt   time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at" db:"updated_at"`
    DeletedAt   *time.Time `json:"deleted_at,omitempty" db:"deleted_at"` // nullable, soft delete
}
```
- Go field names stay PascalCase (language rule, unavoidable)
- The `json:"..."` tag **must** be snake_case exactly matching the database column — this, not the Go field name, defines the field shape in the API response
- Nullable fields (`created_by`, `updated_by`, `deleted_at`) use pointers (`*string`, `*time.Time`) per the Golang idiom for nullable values, not an ambiguous zero value (`""` could mean "actually empty" or "not set yet")
- With `sqlx` or GORM, the `db:"..."`/`gorm:"column:..."` tag must also be snake_case matching the `json` tag, so query rows and API responses stay consistent with each other

### 2.5 Database — Tables, Fields, and Relations

#### Table Names
- snake_case, **plural**, English: `users`, `order_items`, `warehouse_stocks`
- Many-to-many junction/pivot table: `{table1}_{table2}` in **alphabetical** order, singular without double plural: `role_user`, `order_product`
- History/log table: suffix `_logs` or `_histories`: `stock_movement_logs`, `order_status_histories`
- Avoid application prefixes (`tbl_`, `app_users`) unless there's a real multi-schema need

#### Field/Column Names
| Element | Convention | Example |
|---|---|---|
| Primary key | `id` (not `{table}_id` on its own table), **default type UUID** (not auto-increment integer) | `id` — UUID, e.g. `a1b2c3d4-...` |
| Foreign key | `{singular_referenced_table}_id` | `user_id`, `order_id`, `warehouse_id` |
| Boolean | `is_` / `has_` prefix | `is_active`, `has_verified_email` |
| Timestamp | past tense + `_at` | `created_at`, `updated_at`, `deleted_at`, `approved_at`, `shipped_at` |
| Date (no time) | `_date` suffix | `birth_date`, `due_date` |
| Money amount/price | `_amount` or `_price` suffix, store as integer/decimal (avoid float) | `total_amount`, `unit_price` |
| Status/enum | singular, clear noun | `status`, `payment_status` (not `is_status`) |
| Unique code/number | `_code` / `_number` suffix | `order_code`, `invoice_number` |
| Counter/count | `total_` prefix or `_count` suffix | `total_items`, `retry_count` |
| JSON/metadata field | `_json` or `_meta` suffix (makes clear it's not a relation) | `shipping_address_json`, `extra_meta` |

**Avoid:**
- Ambiguous field names: `type`, `value`, `data` without table context → use `order_type`, `discount_value`
- Database reserved words as column names (`order`, `group`, `user` without context) — if unavoidable, wrap with quoting per driver

**Primary key — UUID by default:**
- All new tables use UUID (usually v4, or v7 if time-ordering is needed — check library/DB support) as `id`, not auto-increment integer, unless there's a specific reason to deviate (e.g. a purely internal table never exposed to the API/client at all, with very high volume so an integer index is lighter — rare; the default stays UUID)
- Why: IDs can't be guessed/enumerated by outsiders (auto-increment integers leak data volume and are easy to iterate `?id=1,2,3...`), are safe in URLs/API responses without exposing internal info, and don't conflict if data ever needs merging from multiple sources/environments (migration, cross-system sync)
- Setup per stack:
  - PostgreSQL: `gen_random_uuid()` (built into Postgres 13+) or the `uuid-ossp` extension
  - Prisma: `@id @default(uuid())` or `@default(dbgenerated("gen_random_uuid()"))` to generate at DB level
  - TypeORM: `@PrimaryGeneratedColumn('uuid')`
  - Laravel: `$table->uuid('id')->primary()` in the migration, `HasUuids` trait on the model
  - Golang/GORM: `ID string \`gorm:"type:uuid;default:gen_random_uuid()"\``

#### Required Columns (default convention for every table, unless there's a specific reason)
```
id            (PK, UUID)
...           (table-specific fields)
created_by    (FK to users, nullable — nullable for rows created by system/automated jobs with no user actor)
updated_by    (FK to users, nullable — nullable for the same case)
created_at
updated_at
deleted_at    (nullable, if using soft delete)
```

- `created_by`/`updated_by` **are required** for tables whose data users (not just the system) can change — especially tables that also need an audit log (see section 5.4): these two columns complement the audit log with a quick view of "who last touched this row" without querying the separate `audit_logs` table
- For tables **only ever written by the system** (logs, cache, automated-job output with no user involvement at all), `created_by`/`updated_by` may be skipped — don't force them where irrelevant
- `created_by`/`updated_by` are nullable because some inserts/updates come from jobs/system with no responsible user (auto-order, sync job, seed data) — don't force `NOT NULL`, which would later require a fake dummy user
- Indexes on `created_by`/`updated_by` are optional; add them if there's a real need to filter/query by these columns (see section 2.5 Index & Constraint)

#### Relations Between Tables

**One-to-Many** (1 order has many order_items)
- FK goes on the "many" table: `order_items.order_id → orders.id`
- ORM relation names: parent → `items()`/`orderItems()` (hasMany), child → `order()` (belongsTo)

**Many-to-Many** (users ↔ roles)
- Must go through a pivot table: `role_user` (columns: `role_id`, `user_id`, plus `created_at` if history is needed)
- If the pivot needs extra data (e.g. `assigned_at`, `assigned_by`), consider promoting it to its own entity table with a descriptive name, not just a pivot: e.g. `order_product` → becomes `order_items` when it has `quantity`, `price_at_order_time`, etc.

**One-to-One** (users ↔ user_profiles)
- FK on the "dependent" table (the one with optional/extra data): `user_profiles.user_id`
- Put a unique constraint on the FK so it's truly 1:1

**Self-referencing** (categories with sub-categories, employee with manager)
- FK points to its own table with a descriptive, not generic, name: `categories.parent_category_id`, `employees.manager_id` (not plain `parent_id` if the context could be ambiguous)

**Polymorphic relation** (e.g. `comments` can belong to `posts` or `products`)
- Use the column pair `{name}able_id` + `{name}able_type`: `commentable_id`, `commentable_type` (Laravel convention) — for NestJS/TypeORM, create 2 separate nullable FKs or a junction table per type if you want to stay relationally strict

#### Index & Constraint
- Index every foreign key: `idx_{table}_{column}` → `idx_order_items_order_id`
- Index columns frequently used in filters/where: `idx_orders_status`, `idx_users_email`
- Explicitly named unique constraint: `uniq_{table}_{column}` → `uniq_users_email`
- Composite index for frequently used combined queries: `idx_orders_user_id_status`
