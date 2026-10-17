# Coding Standards — ORM & Database Access

> Part of the `coding-standards` skill. Section numbers are kept so references like "section 3.1" stay valid.

## 3. ORM & Database Access Standard (Node.js & Golang)

Pick one ORM/query approach per project; don't mix within one service. The standards below build on the section 2.5 naming convention (table/field/relation names stay the same; this is about implementation in code).

> **Migration discipline principles — apply to every ORM below, stressed here because they're a frequent source of production incidents:**
> - **Production schema is never changed directly.** Every table-structure change goes through a migration file committed to version control (`prisma migrate`, `typeorm migration:generate`, `golang-migrate`/`goose`) — not via a database GUI, not `db push`/`AutoMigrate()`/`synchronize: true` in production.
> - **Migrations are tested in development/staging first** before running in production, including checking that the migration can be rolled back (a correct `down()`, not an empty formality).
> - **Schema changes that could damage existing data** (drop column, change data type, add a `NOT NULL` column without default) need a staged migration strategy (add nullable column first → backfill data → then set the constraint), not one directly destructive migration — especially for tables that already hold production data.
> - When working in a team/project where many people touch the same schema, consider a branch-per-schema-change workflow (schema change on a separate branch, reviewed before merge) so migration conflicts surface before production, not after.

### 3.1 Prisma (v7 and up)

Prisma 7 has several important changes from earlier versions — make sure new project setup follows this. *(Note: specific syntax such as `prisma.config.ts` follows Prisma 7 as of writing this skill — for a new project where a newer Prisma version exists, check the official Prisma changelog for breaking changes before following the patterns below as-is.)*

**Client generator (Rust-free client required in v7+):**
```prisma
generator client {
  provider = "prisma-client"   // not "prisma-client-js" (old/Rust-based)
  output   = "../src/generated/prisma"
}
```
- `output` **must** point inside the project source (e.g. `src/generated/prisma`), not the old `node_modules` default — this is Prisma 7's default behavior; don't override it back to node_modules
- Add the generated folder to `.gitignore`

**Project configuration — use `prisma.config.ts`:**
Prisma 7 moves project configuration (schema location, seed script, database URL) into a separate config file, no longer in `package.json` or the schema:
```typescript
// prisma.config.ts
import { defineConfig } from 'prisma/config';
import 'dotenv/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    seed: 'ts-node prisma/seed.ts',
  },
});
```

**Naming in schema.prisma — snake_case fields directly, WITHOUT `@map`:**

Because entity fields must be identical to database column names (section 2.2), Prisma schema fields are **written directly in snake_case**, not camelCase + `@map`. This matters so an object built from query params (`req.query`) can be used directly as a `where` clause without transformation:

```prisma
model OrderItem {
  id          String    @id @default(uuid())
  order_id    String
  product_id  String
  quantity    Int
  created_by  String?
  updated_by  String?
  created_at  DateTime  @default(now())
  updated_at  DateTime  @updatedAt
  deleted_at  DateTime?

  order   Order   @relation(fields: [order_id], references: [id])
  product Product @relation(fields: [product_id], references: [id])

  @@map("order_items")
  @@index([order_id], map: "idx_order_items_order_id")
}
```
- Model name stays PascalCase singular (`model OrderItem`), mapped to the table via `@@map("order_items")` — the only `@map` still used (table name); column fields need no `@map` since they already match exactly
- `id` defaults to `String @id @default(uuid())` — UUID as default primary key (see section 2.5)
- `created_by`/`updated_by`/`deleted_at` nullable (`String?`/`DateTime?`) per the required columns in section 2.5 — skip them if the table is only written by the system with no user involvement
- Enum: PascalCase name, UPPER_SNAKE_CASE values, `@@map` required for the enum's DB table name when relevant

**Direct benefit for multi-field queries & relation filters:**
```typescript
// Request query params become the where clause directly, no manual mapping
// GET /api/v1/orders?status=pending&user_id=abc&items.product_id=xyz
const { status, user_id, ...filters } = req.query;

const orders = await prisma.order.findMany({
  where: {
    ...(status && { status }),
    ...(user_id && { user_id }),
    ...(filters['items.product_id'] && {
      items: { some: { product_id: filters['items.product_id'] } },
    }),
  },
});
```
Because Prisma Client field names exactly match column/relation names, no `camelCase → snake_case` conversion layer is needed before building dynamic queries.

**Folder structure for NestJS integration:**
```
src/
├── prisma/
│   ├── prisma.service.ts     # wraps PrismaClient as an injectable service
│   └── prisma.module.ts
├── generated/prisma/          # generated output, in .gitignore
└── modules/
    └── order/
        └── order.repository.ts   # Prisma queries live here, not directly in the service
```

**Query rules:**
- Don't call `PrismaClient` directly in a service/controller — wrap it via `PrismaService` (injectable) and put complex queries in the repository layer
- Avoid N+1: use explicit `include`/`select`, no queries inside loops
- Multi-step transactions must use `prisma.$transaction([...])` or an interactive transaction, not multiple separate queries without rollback safety
- Migration: `prisma migrate dev` for development, `prisma migrate deploy` for production — never `db push` in production

### 3.2 TypeORM

**Entity naming — snake_case fields directly, WITHOUT `name` mapping:**

As with Prisma, entity class fields are **written directly in snake_case** matching column names, not camelCase + `@Column({ name: '...' })`. Same goal: entity fields can be used directly to build a dynamic `where` from query params without transformation.

```typescript
@Entity('order_items')
export class OrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  order_id: string;

  @ManyToOne(() => Order, (order) => order.items)
  @JoinColumn({ name: 'order_id' })
  order: Order;

  @Column({ type: 'int' })
  quantity: number;

  @Column({ nullable: true })
  created_by: string;

  @Column({ nullable: true })
  updated_by: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;
}
```
- Must declare the table name explicitly in `@Entity('table_name')`; don't rely on auto-generation from the class name
- `@PrimaryGeneratedColumn('uuid')` — UUID as default primary key (see section 2.5), not plain `@PrimaryGeneratedColumn()` which is auto-increment integer
- `created_by`/`updated_by` nullable, `deleted_at` uses `@DeleteDateColumn()` (TypeORM automatically excludes rows with `deleted_at` from normal queries when soft delete is enabled via `softDelete()`) — per the required columns in section 2.5
- `@JoinColumn({ name: '...' })` still needs to be stated explicitly for relations (TypeORM needs it to know the FK column), but the foreign key column name itself stays snake_case like any other field

**Multi-field query & relation filter:**
```typescript
const { status, order_id, product_id } = req.query;

const orders = await orderRepository.find({
  where: {
    ...(status && { status }),
    ...(order_id && { id: order_id }),
    ...(product_id && { items: { product_id } }),  // filter via relation directly
  },
  relations: ['items'],
});
```

**Folder structure:** entities go in `entities/` per module (see NestJS structure section 4.1), custom repositories via `@InjectRepository` in the service; don't put complex query builders directly in the controller.

**Query rules:**
- Use `QueryBuilder` for complex/multi-table-join queries, built-in `Repository` methods (`find`, `findOne`) for simple cases
- Set `relations` explicitly in queries; don't overuse `eager: true` on every relation (causes over-fetching)
- Migrations must be generated via CLI (`typeorm migration:generate`); no `synchronize: true` in production — it risks data loss

### 3.3 Choosing Between Prisma vs TypeORM

| Criterion | Prisma | TypeORM |
|---|---|---|
| Type-safety | Stronger (auto-generated types) | Decent, but manual in some cases |
| Control over complex SQL | Limited, `$queryRaw` as fallback | More flexible via QueryBuilder |
| Best for | New projects, API-first, teams wanting fast DX | Projects with complex relations/legacy schema, needing more control |

For a new project with no special constraints, **Prisma (v7+) is the default choice** for its better type-safety and DX.

### 3.4 Golang — GORM or sqlx

**GORM** (full ORM, suited to standard CRUD and relations):
```go
type Order struct {
    ID          string    `json:"id" gorm:"column:id;primaryKey"`
    UserID      string    `json:"user_id" gorm:"column:user_id"`
    OrderCode   string    `json:"order_code" gorm:"column:order_code"`
    TotalAmount float64   `json:"total_amount" gorm:"column:total_amount"`
    Items       []OrderItem `json:"items" gorm:"foreignKey:OrderID"`
    CreatedAt   time.Time `json:"created_at" gorm:"column:created_at"`
}

func (Order) TableName() string { return "orders" }   // must be explicit; don't rely on GORM's automatic pluralization
```

**Multi-field query & relation filter with GORM** — since the `json` and `gorm:"column:"` tags are already in sync as snake_case, query params map directly to `Where`:
```go
func (r *OrderRepository) FindOrders(filters map[string]interface{}) ([]Order, error) {
    query := r.db.Model(&Order{})
    if status, ok := filters["status"]; ok {
        query = query.Where("status = ?", status)
    }
    if userID, ok := filters["user_id"]; ok {
        query = query.Where("user_id = ?", userID)
    }
    if productID, ok := filters["product_id"]; ok {
        query = query.Joins("JOIN order_items ON order_items.order_id = orders.id").
            Where("order_items.product_id = ?", productID)
    }
    var orders []Order
    err := query.Preload("Items").Find(&orders).Error
    return orders, err
}
```

**sqlx** (when you need full SQL control, raw queries with struct scanning):
```go
type Order struct {
    ID          string    `db:"id" json:"id"`
    UserID      string    `db:"user_id" json:"user_id"`
    TotalAmount float64   `db:"total_amount" json:"total_amount"`
}

var orders []Order
err := db.Select(&orders, "SELECT * FROM orders WHERE status = $1 AND user_id = $2", status, userID)
```

**Rules:**
- The repository layer must be separate from handlers (see folder structure 4.5) — handlers must not call GORM/sqlx directly
- Migrations use a separate tool (`golang-migrate`, `goose`, or `atlas`); no GORM `AutoMigrate()` in production — same as the `synchronize: true` ban in TypeORM
- Avoid N+1: use explicit `Preload()` (GORM) for needed relations, no queries inside loops
- Multi-step transactions must use `db.Transaction(func(tx *gorm.DB) error { ... })`, not multiple separate queries without rollback safety

### 3.5 Supabase

Supabase runs plain PostgreSQL underneath, so the database naming convention (section 2.5) applies exactly the same. The difference from traditional ORMs: data access via the Supabase client (REST/JS SDK) often happens directly from certain sides without a custom backend, so **data security moves to the database level** via Row Level Security (RLS) — no longer guarded in the service layer as with Prisma/TypeORM/GORM.

**Row Level Security (RLS) — must be enabled on every table accessed client-side:**
```sql
-- Enable RLS on the table (required; default OFF means every row is accessible to anyone)
alter table public.orders enable row level security;

-- Policy: users can only see their own orders
create policy "users_select_own_orders"
on public.orders for select
using (auth.uid() = user_id);

-- Policy: users can only insert orders for themselves
create policy "users_insert_own_orders"
on public.orders for insert
with check (auth.uid() = user_id);
```

**Rules:**
- **Tables accessed directly from the client (browser/mobile) via the Supabase SDK must have RLS enabled and explicit policies** — if RLS is off or no policy exists, the table's data can be read/changed by anyone with the anon key (which lives in frontend code, so it isn't secret)
- Policy naming: `{role/scope}_{action}_{scope}`, descriptive — `users_select_own_orders`, `admin_select_all_orders`, `vendor_update_own_menus` — not generic names like `policy1`
- Tables accessed **only** from your own backend (not directly from the client) should still have RLS on with a policy restricting to `service_role` only; don't rely on "only the backend accesses it anyway" as the sole protection — defense in depth (see the principle in `debug-assistant`)
- **Never expose the `service_role` key to the frontend** — it bypasses all RLS; use it only on the server/edge functions, stored as a secret (see section 8.2)
- Edge Functions (if used) follow the same folder structure & error handling as the TypeScript conventions in section 2.2/5 — short functions, single responsibility, errors thrown with clear messages
- Supabase schema migrations still go through migration files (`supabase migration new`, `supabase db push` in the right direction — local to remote via controlled CI/CD, not direct edits in the production dashboard) — the migration discipline principles in section 3 apply in full
