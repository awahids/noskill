# Coding Standards — Naming per Stack & Database

> Bagian dari skill `coding-standards`. Nomor bagian dipertahankan supaya rujukan seperti "bagian 2.5" tetap valid.

### 2.2 TypeScript / JavaScript (NestJS, Next.js, Vue)

| Elemen | Konvensi | Contoh |
|---|---|---|
| Variable, function (logic internal) | camelCase | `userProfile`, `fetchOrderList()` |
| Class, Interface, Type | PascalCase | `UserService`, `OrderDto` |
| Interface | Tanpa prefix `I` | `User` bukan `IUser` |
| Enum | PascalCase (nama) | `enum OrderStatus { Pending, Completed }` |
| File (NestJS) | kebab-case + suffix jenis | `user.service.ts`, `create-order.dto.ts` |
| File (Vue component) | PascalCase | `UserProfileCard.vue` |
| File (Next.js route) | kebab-case | `app/order-history/page.tsx` |
| Folder | kebab-case | `order-management/` |

> **PENTING — Aturan khusus field entity/DTO/API contract:** Aturan camelCase di atas berlaku untuk variable dan function **logic internal** (di luar data yang mengalir dari/ke database). Untuk **field pada Entity, DTO, Request/Response, dan Model** — field-nya **wajib snake_case, sama persis dengan nama kolom database** (lihat bagian 2.5). Ini disengaja: field API dan entity harus identik dengan nama kolom supaya bisa dipakai langsung untuk query multi-field dan filter relasi tanpa layer mapping/transformasi.
>
> ```typescript
> // ✅ Entity/DTO — field sama persis dengan kolom database
> export class Order {
>   id: string;
>   user_id: string;
>   order_code: string;
>   total_amount: number;
>   created_at: Date;
> }
>
> // ✅ Function/variable logic internal — tetap camelCase
> function calculateShippingFee(order: Order): number { ... }
> const isEligibleForDiscount = order.total_amount > 100000;
> ```
> Field object literal/JSON yang jadi contract API (request body, response body, query params) selalu snake_case. Nama function, class, dan variable lokal yang bukan representasi langsung dari data DB tetap camelCase seperti biasa.

### 2.3 PHP (Laravel)

| Elemen | Konvensi | Contoh |
|---|---|---|
| Class | PascalCase | `OrderService`, `UserController` |
| Method, variable (logic internal) | camelCase | `getActiveUsers()`, `$totalAmount` |
| Field Model/Resource/Request (data DB) | snake_case, sama dengan kolom | `$order->user_id`, `$order->total_amount` |
| File | Sesuai nama class (PSR-4) | `OrderService.php` |
| Migration | snake_case + timestamp prefix | `2025_01_10_create_orders_table.php` |
| Config key | snake_case | `payment_gateway_url` |

> Laravel/Eloquent secara default sudah snake_case untuk atribut model — jadi aturan ini natural di Laravel tanpa penyesuaian tambahan. Yang perlu dijaga: API Resource (`toArray()`) jangan diubah ke camelCase, kembalikan field apa adanya sesuai nama kolom.

### 2.4 Golang (Gin/Fiber)

Go punya aturan bahasa sendiri soal casing yang tidak bisa disamakan persis dengan TypeScript/PHP — exported identifier **wajib** diawali huruf kapital (ini aturan compiler, bukan gaya). Jadi field parity dengan database dicapai lewat **struct tag**, bukan nama field Go itu sendiri.

| Elemen | Konvensi | Contoh |
|---|---|---|
| Package name | lowercase, satu kata, tanpa underscore | `package order`, `package handler` |
| Struct, Interface | PascalCase | `type OrderService struct`, `type OrderRepository interface` |
| Exported function/method | PascalCase | `func GetOrderByID(id string)` |
| Unexported function/variable (internal ke package) | camelCase | `func calculateTotal(items []Item) int` |
| Struct field (exported, wajib untuk JSON/DB) | PascalCase field name + tag snake_case | `OrderID string \`json:"order_id" db:"order_id"\`` |
| File | snake_case | `order_service.go`, `order_repository.go` |
| Konstanta | PascalCase atau UPPER_SNAKE_CASE (konsisten per project) | `const MaxRetryCount = 3` |
| Error variable | prefix `Err` | `var ErrOrderNotFound = errors.New("order not found")` |

**Field struct wajib pakai tag untuk field parity dengan database/API (menyambung aturan bagian 2.2):**
```go
type Order struct {
    ID          string     `json:"id" db:"id"`                   // UUID, lihat bagian 2.5
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
- Nama field Go tetap PascalCase (aturan bahasa, tidak bisa dihindari)
- Tag `json:"..."` **wajib** snake_case sama persis dengan kolom database — inilah yang menentukan bentuk field di response API, bukan nama field Go
- Field nullable (`created_by`, `updated_by`, `deleted_at`) pakai pointer (`*string`, `*time.Time`) sesuai idiom Golang untuk nullable value, bukan zero-value yang ambigu (`""` bisa berarti "memang kosong" atau "belum di-set")
- Kalau pakai `sqlx` atau GORM, tag `db:"..."`/`gorm:"column:..."` juga wajib snake_case sama dengan `json` tag, supaya row hasil query dan response API konsisten satu sama lain

### 2.5 Database — Tabel, Field, dan Relasi

#### Nama Tabel
- snake_case, **plural**, bahasa Inggris: `users`, `order_items`, `warehouse_stocks`
- Tabel junction/pivot untuk many-to-many: `{table1}_{table2}` urut **alfabetis**, singular tanpa plural ganda: `role_user`, `order_product`
- Tabel histori/log: suffix `_logs` atau `_histories`: `stock_movement_logs`, `order_status_histories`
- Hindari prefix aplikasi (`tbl_`, `app_users`) kecuali memang ada kebutuhan multi-schema

#### Nama Field/Kolom
| Elemen | Konvensi | Contoh |
|---|---|---|
| Primary key | `id` (jangan `{table}_id` di tabel sendiri), **tipe default UUID** (bukan auto-increment integer) | `id` — UUID, contoh `a1b2c3d4-...` |
| Foreign key | `{singular_referenced_table}_id` | `user_id`, `order_id`, `warehouse_id` |
| Boolean | prefix `is_` / `has_` | `is_active`, `has_verified_email` |
| Timestamp | past tense + `_at` | `created_at`, `updated_at`, `deleted_at`, `approved_at`, `shipped_at` |
| Tanggal (tanpa jam) | suffix `_date` | `birth_date`, `due_date` |
| Jumlah/nominal uang | suffix `_amount` atau `_price`, simpan sebagai integer/decimal (hindari float) | `total_amount`, `unit_price` |
| Status/enum | singular, noun jelas | `status`, `payment_status` (bukan `is_status`) |
| Kode/nomor unik | suffix `_code` / `_number` | `order_code`, `invoice_number` |
| Counter/jumlah | prefix `total_` atau suffix `_count` | `total_items`, `retry_count` |
| Field JSON/metadata | suffix `_json` atau `_meta` (jelas isinya bukan relasi) | `shipping_address_json`, `extra_meta` |

**Hindari:**
- Nama field ambigu: `type`, `value`, `data` tanpa konteks tabel → gunakan `order_type`, `discount_value`
- Reserved word database sebagai nama kolom (`order`, `group`, `user` tanpa konteks) — kalau terpaksa, wrap dengan quoting sesuai driver

**Primary key — UUID sebagai default:**
- Semua tabel baru pakai UUID (v4 umumnya, atau v7 kalau butuh urut secara waktu — cek dukungan library/DB) sebagai `id`, bukan auto-increment integer, kecuali ada alasan spesifik untuk menyimpang (misal tabel internal murni yang tidak pernah diekspos ke API/client sama sekali dan volume sangat besar sehingga index integer lebih ringan — kasus ini jarang, defaultnya tetap UUID)
- Alasan: ID tidak bisa ditebak/dienumerasi oleh pihak luar (auto-increment integer bocor jumlah data dan gampang di-iterate `?id=1,2,3...`), aman dipakai di URL/response API tanpa expose informasi internal, dan tidak konflik kalau suatu saat perlu merge data dari beberapa sumber/environment (migrasi, sync antar sistem)
- Setup per stack:
  - PostgreSQL: `gen_random_uuid()` (built-in di Postgres 13+) atau extension `uuid-ossp`
  - Prisma: `@id @default(uuid())` atau `@default(dbgenerated("gen_random_uuid()"))` untuk generate di level DB
  - TypeORM: `@PrimaryGeneratedColumn('uuid')`
  - Laravel: `$table->uuid('id')->primary()` di migration, trait `HasUuids` di model
  - Golang/GORM: `ID string \`gorm:"type:uuid;default:gen_random_uuid()"\``

#### Kolom Wajib (konvensi default tiap tabel, kecuali ada alasan khusus)
```
id            (PK, UUID)
...           (field spesifik tabel)
created_by    (FK ke users, nullable — nullable untuk kasus dibuat sistem/job otomatis tanpa aktor user)
updated_by    (FK ke users, nullable — nullable untuk kasus yang sama)
created_at
updated_at
deleted_at    (nullable, kalau pakai soft delete)
```

- `created_by`/`updated_by` **wajib ada** untuk tabel yang datanya bisa diubah oleh user (bukan cuma sistem) — terutama tabel yang juga butuh audit log (lihat bagian 5.4): dua kolom ini melengkapi audit log dengan cara cepat lihat "siapa terakhir yang pegang row ini" tanpa harus query tabel `audit_logs` terpisah
- Untuk tabel yang **cuma pernah ditulis oleh sistem** (log, cache, tabel hasil job otomatis tanpa keterlibatan user sama sekali), `created_by`/`updated_by` boleh dilewatkan — jangan dipaksakan kalau memang tidak relevan
- `created_by`/`updated_by` nullable karena beberapa insert/update terjadi dari job/sistem tanpa user yang bertanggung jawab (auto-order, sync job, seed data) — jangan dipaksa `NOT NULL` yang nanti butuh user dummy palsu
- Index untuk `created_by`/`updated_by` opsional, tambahkan kalau memang ada kebutuhan filter/query berdasarkan kolom ini (lihat bagian 2.5 Index & Constraint)

#### Relasi Antar Tabel

**One-to-Many** (1 order punya banyak order_items)
- FK diletakkan di tabel "many": `order_items.order_id → orders.id`
- Nama relasi di ORM: parent → `items()`/`orderItems()` (hasMany), child → `order()` (belongsTo)

**Many-to-Many** (users ↔ roles)
- Wajib lewat tabel pivot: `role_user` (kolom: `role_id`, `user_id`, plus `created_at` jika perlu histori)
- Kalau pivot butuh data tambahan (misal `assigned_at`, `assigned_by`), pertimbangkan naikkan jadi tabel entitas sendiri dengan nama deskriptif, bukan sekadar pivot: contoh `order_product` → jadi `order_items` kalau ada `quantity`, `price_at_order_time`, dll

**One-to-One** (users ↔ user_profiles)
- FK di tabel "dependent" (tabel yang datanya opsional/tambahan): `user_profiles.user_id`
- Beri unique constraint di FK-nya supaya benar-benar 1:1

**Self-referencing** (kategori dengan sub-kategori, employee dengan manager)
- FK menunjuk ke tabel sendiri dengan nama deskriptif, bukan generik: `categories.parent_category_id`, `employees.manager_id` (bukan `parent_id` polos kalau konteksnya bisa ambigu)

**Polymorphic relation** (misal `comments` bisa milik `posts` atau `products`)
- Gunakan pasangan kolom `{name}able_id` + `{name}able_type`: `commentable_id`, `commentable_type` (konvensi Laravel) — untuk NestJS/TypeORM, buat 2 FK nullable terpisah atau tabel junction per tipe kalau ingin tetap relational-strict

#### Index & Constraint
- Index untuk semua foreign key: `idx_{table}_{column}` → `idx_order_items_order_id`
- Index untuk kolom yang sering jadi filter/where: `idx_orders_status`, `idx_users_email`
- Unique constraint eksplisit dinamai: `uniq_{table}_{column}` → `uniq_users_email`
- Composite index untuk query gabungan yang sering dipakai: `idx_orders_user_id_status`
