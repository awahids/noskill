---
name: coding-standards
description: Standar penamaan (naming convention), struktur folder/proyek, dan konvensi kode untuk stack NestJS, Laravel, Golang/Gin, Vue.js, Next.js, TypeScript, PHP, dan database (PostgreSQL/MySQL). Gunakan skill ini setiap kali menulis kode baru, membuat file/folder baru, menamai variable/function/class/struct, mendesain endpoint API, membuat migration database, atau melakukan code review — bahkan jika user tidak secara eksplisit menyebut "standar" atau "convention". Wajib dipakai sebagai acuan saat user memakai frasa seperti "sesuai standar kita", "code review", "buatkan struktur folder", "naming yang benar", atau saat generate kode untuk project Rasa Group / proyek pribadi Wahid (Proyatim, aw-prd, dll) — termasuk project Golang/Gin seperti sistem absensi.
---

# Coding Standards — Acuan Penulisan & Review Kode

Skill ini adalah standar coding pribadi/tim untuk stack: **NestJS, Laravel, Vue.js, Next.js, TypeScript, PHP, PostgreSQL/MySQL**.

Gunakan standar ini SETIAP KALI:
- Menulis kode baru (function, class, component, endpoint, migration)
- Membuat file atau folder baru
- Melakukan code review (jadikan checklist di bagian akhir sebagai acuan)
- Mendesain struktur API/response

Jika stack yang dipakai user berbeda dari yang tercakup di sini, tetap terapkan **prinsip umum** (bagian 1 & 2.1) dan sesuaikan secara wajar.

---

## 1. Prinsip Umum

1. Konsistensi lebih penting daripada preferensi pribadi — ikuti standar ini meskipun ada cara lain yang valid.
2. Readability first — kode dibaca jauh lebih sering daripada ditulis.
3. Explicit lebih baik daripada implicit — hindari "magic" yang bikin orang lain menebak.
4. DRY tapi jangan over-abstract — duplikasi 2x masih oke, baru pertimbangkan abstraksi di duplikasi ke-3.
5. Fail fast, fail loud — validasi input di awal, jangan biarkan error menyebar diam-diam.
6. **Refactor besar butuh rencana dulu, bukan langsung diubah.** Untuk refactor yang menyentuh banyak file/mengubah struktur (bukan sekadar rename kecil atau simplify pass di bagian 5.3), tulis dulu rencana step-by-step sebelum menyentuh kode: apa yang diubah, urutan langkahnya, bagaimana memverifikasi tiap langkah tidak merusak yang sudah jalan. Refactor tanpa rencana punya risiko besar memperbaiki satu hal sambil merusak hal lain yang tidak diperhatikan — terutama berbahaya di logic yang sudah dipakai production. Rencana ini bisa singkat (bullet list) untuk refactor kecil, atau lebih detail (mirip task breakdown di skill `task-breakdown`) untuk refactor besar lintas modul.
7. **Surgical changes — sentuh cuma yang diminta.** Kalau task-nya "perbaiki bug X", jangan sekalian reformat file, ganti gaya penulisan, atau "membenahi" kode di sekitarnya yang tidak diminta — meskipun menurut penilaian sendiri itu lebih baik. Perubahan yang tidak diminta bikin diff susah direview (perubahan penting tenggelam di antara perubahan kosmetik) dan berisiko mengubah perilaku yang tidak dimaksud. Kalau ketemu kode di sekitarnya yang jelas bermasalah tapi di luar scope task, **sebutkan** ke user sebagai catatan terpisah — jangan langsung diubah tanpa diminta. Simplify pass (5.3) dan refactor terencana (poin 6) adalah pengecualian sah karena memang itu tujuannya, tapi tetap sebagai task tersendiri yang eksplisit, bukan menumpang di task lain.
8. **Nyatakan asumsi secara eksplisit, jangan diam-diam pilih satu.** Kalau requirement/instruksi punya lebih dari satu interpretasi yang masuk akal, sebutkan interpretasi mana yang dipakai dan kenapa — jangan langsung jalan dengan satu asumsi tanpa bilang. Ini beda dari "selalu bertanya dulu": untuk hal yang bisa diputuskan dengan asumsi wajar, tetap jalan, tapi asumsinya ditulis eksplisit (misal di komentar, di ringkasan awal jawaban, atau di PR description) supaya user bisa koreksi kalau asumsinya salah, alih-alih ketahuan salah setelah kode sudah jauh berjalan.

---

## 2. Naming Convention

### 2.1 Umum (berlaku semua bahasa)

| Elemen | Konvensi | Contoh |
|---|---|---|
| Boolean | Prefix `is`, `has`, `can`, `should` | `isActive`, `hasPermission`, `canEdit` |
| Function/Method | Kata kerja + objek | `getUserById()`, `calculateTotalPrice()` |
| Event handler | Prefix `on` / `handle` | `onSubmit`, `handleClick` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Private/internal | Prefix `_` (jika bahasa tidak punya `private` native) | `_calculateInternal()` |

Hindari: nama generik (`data`, `temp`, `obj`), singkatan tidak jelas (`usr`, `qty`), nama yang menyesatkan (fungsi `getUser` yang juga menghapus data).

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

---

## 3. ORM & Database Access Standard (Node.js & Golang)

Pilih satu ORM/query approach per project, jangan campur dalam satu service. Standar di bawah berlaku di atas naming convention bagian 2.5 (nama tabel/field/relasi tetap sama, ini soal cara implementasi di kode).

> **Prinsip disiplin migration — berlaku untuk semua ORM di bawah, ditegaskan di sini karena sering jadi sumber insiden production:**
> - **Schema production tidak pernah diubah langsung.** Semua perubahan struktur tabel lewat file migration yang di-commit ke version control (`prisma migrate`, `typeorm migration:generate`, `golang-migrate`/`goose`) — bukan lewat GUI database, bukan `db push`/`AutoMigrate()`/`synchronize: true` di environment production.
> - **Migration dites di environment development/staging dulu** sebelum dijalankan ke production, termasuk cek apakah migration bisa di-rollback (`down()` yang benar, bukan sekadar formalitas kosong).
> - **Perubahan schema yang berpotensi merusak data existing** (drop column, ubah tipe data, tambah kolom `NOT NULL` tanpa default) butuh strategi migrasi bertahap (tambah kolom nullable dulu → backfill data → baru set constraint), bukan satu migration langsung destruktif — terutama untuk tabel yang sudah ada data production.
> - Kalau kerja di tim/project dengan banyak orang menyentuh schema yang sama, pertimbangkan workflow branch-per-perubahan-schema (schema change di branch terpisah, direview sebelum merge) supaya konflik migration ketahuan sebelum sampai production, bukan sesudahnya.

### 3.1 Prisma (v7 ke atas)

Prisma 7 punya beberapa perubahan penting dari versi sebelumnya — pastikan setup project baru mengikuti ini. *(Catatan: sintaks spesifik seperti `prisma.config.ts` mengikuti Prisma 7 saat skill ini ditulis — kalau ada project baru dan sudah ada versi Prisma yang lebih baru, cek dulu changelog resmi Prisma untuk perubahan breaking sebelum mengikuti pola di bawah ini apa adanya.)*

**Generator client (wajib Rust-free client di v7+):**
```prisma
generator client {
  provider = "prisma-client"   // bukan "prisma-client-js" (versi lama/Rust-based)
  output   = "../src/generated/prisma"
}
```
- `output` **wajib** diarahkan ke dalam source project (misal `src/generated/prisma`), bukan default lama di `node_modules` — ini perilaku default Prisma 7, jangan override balik ke node_modules
- Tambahkan folder hasil generate ke `.gitignore`

**Konfigurasi project — gunakan `prisma.config.ts`:**
Prisma 7 memisahkan konfigurasi project (lokasi schema, seed script, database URL) ke file config terpisah, bukan lagi ditaruh di `package.json` atau schema:
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

**Naming di schema.prisma — field snake_case langsung, TANPA `@map`:**

Karena field entity wajib identik dengan nama kolom database (bagian 2.2), field di schema Prisma **ditulis langsung snake_case**, bukan camelCase + `@map`. Ini penting supaya object yang dibangun dari query params (`req.query`) bisa langsung dipakai sebagai `where` clause tanpa transformasi:

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
- Model name tetap PascalCase singular (`model OrderItem`), map ke tabel lewat `@@map("order_items")` — ini satu-satunya `@map` yang tetap dipakai (nama tabel), field kolom tidak perlu `@map` lagi karena sudah sama persis
- `id` default `String @id @default(uuid())` — UUID sebagai default primary key (lihat bagian 2.5)
- `created_by`/`updated_by`/`deleted_at` nullable (`String?`/`DateTime?`) sesuai kolom wajib di bagian 2.5 — lewatkan kalau tabelnya memang cuma ditulis sistem tanpa keterlibatan user
- Enum: PascalCase nama, value UPPER_SNAKE_CASE, wajib `@@map` untuk nama tabel enum di DB kalau relevan

**Keuntungan langsung untuk multi-field query & filter relasi:**
```typescript
// Query params dari request bisa langsung jadi where clause, tanpa mapping manual
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
Karena nama field di Prisma Client sama persis dengan nama kolom/relasi, tidak perlu ada layer konversi `camelCase → snake_case` sebelum membangun query dinamis.

**Struktur folder integrasi dengan NestJS:**
```
src/
├── prisma/
│   ├── prisma.service.ts     # wrap PrismaClient sebagai injectable service
│   └── prisma.module.ts
├── generated/prisma/          # hasil generate, di .gitignore
└── modules/
    └── order/
        └── order.repository.ts   # query Prisma ditaruh di sini, bukan langsung di service
```

**Aturan query:**
- Jangan panggil `PrismaClient` langsung di service/controller — wrap lewat `PrismaService` (injectable) dan taruh query kompleks di repository layer
- Hindari N+1: gunakan `include`/`select` eksplisit, jangan query di dalam loop
- Transaksi multi-step wajib pakai `prisma.$transaction([...])` atau interactive transaction, bukan multiple query terpisah tanpa rollback safety
- Migration: `prisma migrate dev` untuk development, `prisma migrate deploy` untuk production — jangan pernah `db push` di production

### 3.2 TypeORM

**Naming entity — field snake_case langsung, TANPA `name` mapping:**

Sama seperti Prisma, field di class entity **ditulis langsung snake_case** mengikuti nama kolom, bukan camelCase + `@Column({ name: '...' })`. Tujuannya sama: field entity bisa langsung dipakai untuk membangun `where` dinamis dari query params tanpa transformasi.

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
- Wajib deklarasikan nama tabel eksplisit di `@Entity('nama_tabel')`, jangan andalkan auto-generate dari nama class
- `@PrimaryGeneratedColumn('uuid')` — UUID sebagai default primary key (lihat bagian 2.5), bukan `@PrimaryGeneratedColumn()` biasa yang auto-increment integer
- `created_by`/`updated_by` nullable, `deleted_at` pakai `@DeleteDateColumn()` (TypeORM otomatis exclude row yang punya `deleted_at` di query biasa kalau soft delete diaktifkan lewat `softDelete()`) — sesuai kolom wajib di bagian 2.5
- `@JoinColumn({ name: '...' })` tetap perlu disebutkan eksplisit untuk relasi (TypeORM butuh ini untuk tahu kolom FK-nya), tapi nama kolom foreign key itu sendiri tetap snake_case sama seperti field biasa

**Query multi-field & filter relasi:**
```typescript
const { status, order_id, product_id } = req.query;

const orders = await orderRepository.find({
  where: {
    ...(status && { status }),
    ...(order_id && { id: order_id }),
    ...(product_id && { items: { product_id } }),  // filter lewat relasi langsung
  },
  relations: ['items'],
});
```

**Struktur folder:** entity ditaruh di `entities/` per modul (lihat struktur NestJS bagian 4.1), repository custom lewat `@InjectRepository` di service, jangan taruh query builder kompleks langsung di controller.

**Aturan query:**
- Gunakan `QueryBuilder` untuk query kompleks/join banyak tabel, `Repository` method bawaan (`find`, `findOne`) untuk kasus sederhana
- Set `relations` eksplisit di query, jangan pakai `eager: true` berlebihan di semua relasi (bikin over-fetching)
- Migration wajib generate lewat CLI (`typeorm migration:generate`), jangan `synchronize: true` di production — ini berisiko data loss

### 3.3 Memilih Antara Prisma vs TypeORM

| Kriteria | Prisma | TypeORM |
|---|---|---|
| Type-safety | Lebih kuat (auto-generated types) | Cukup baik, tapi manual di beberapa kasus |
| Kontrol query SQL kompleks | Terbatas, ada `$queryRaw` untuk fallback | Lebih fleksibel lewat QueryBuilder |
| Cocok untuk | Project baru, API-first, tim yang mau DX cepat | Project dengan relasi kompleks/legacy schema, butuh kontrol lebih |

Untuk project baru tanpa constraint khusus, **Prisma (v7+) jadi default pilihan** karena type-safety dan DX lebih baik.

### 3.4 Golang — GORM atau sqlx

**GORM** (ORM penuh, cocok untuk CRUD standar dan relasi):
```go
type Order struct {
    ID          string    `json:"id" gorm:"column:id;primaryKey"`
    UserID      string    `json:"user_id" gorm:"column:user_id"`
    OrderCode   string    `json:"order_code" gorm:"column:order_code"`
    TotalAmount float64   `json:"total_amount" gorm:"column:total_amount"`
    Items       []OrderItem `json:"items" gorm:"foreignKey:OrderID"`
    CreatedAt   time.Time `json:"created_at" gorm:"column:created_at"`
}

func (Order) TableName() string { return "orders" }   // wajib eksplisit, jangan andalkan pluralization otomatis GORM
```

**Multi-field query & filter relasi dengan GORM** — karena tag `json` dan `gorm:"column:"` sudah sinkron snake_case, query params bisa langsung dipetakan ke `Where`:
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

**sqlx** (kalau butuh kontrol SQL penuh, raw query dengan struct scanning):
```go
type Order struct {
    ID          string    `db:"id" json:"id"`
    UserID      string    `db:"user_id" json:"user_id"`
    TotalAmount float64   `db:"total_amount" json:"total_amount"`
}

var orders []Order
err := db.Select(&orders, "SELECT * FROM orders WHERE status = $1 AND user_id = $2", status, userID)
```

**Aturan:**
- Repository layer wajib terpisah dari handler (lihat struktur folder 4.5) — handler tidak boleh langsung panggil GORM/sqlx
- Migration pakai tool terpisah (`golang-migrate`, `goose`, atau `atlas`), jangan `AutoMigrate()` GORM di production — sama seperti larangan `synchronize: true` di TypeORM
- Hindari N+1: gunakan `Preload()` (GORM) eksplisit untuk relasi yang dibutuhkan, jangan query di dalam loop
- Transaksi multi-step wajib pakai `db.Transaction(func(tx *gorm.DB) error { ... })`, bukan multiple query terpisah tanpa rollback safety

### 3.5 Supabase

Supabase pakai PostgreSQL biasa di baliknya, jadi naming convention database (bagian 2.5) berlaku sama persis. Yang beda dari ORM tradisional: akses data lewat Supabase client (REST/JS SDK) sering langsung dari sisi tertentu tanpa backend custom, jadi **keamanan data berpindah ke level database** lewat Row Level Security (RLS) — bukan lagi dijaga di layer service seperti Prisma/TypeORM/GORM.

**Row Level Security (RLS) — wajib aktif untuk semua tabel yang diakses client-side:**
```sql
-- Aktifkan RLS di tabel (wajib, defaultnya OFF berarti semua row bisa diakses siapa saja)
alter table public.orders enable row level security;

-- Policy: user cuma bisa lihat order miliknya sendiri
create policy "users_select_own_orders"
on public.orders for select
using (auth.uid() = user_id);

-- Policy: user cuma bisa insert order untuk dirinya sendiri
create policy "users_insert_own_orders"
on public.orders for insert
with check (auth.uid() = user_id);
```

**Aturan:**
- **Tabel yang diakses langsung dari client (browser/mobile) via Supabase SDK wajib punya RLS aktif dan policy eksplisit** — kalau RLS mati atau policy belum dibuat, data di tabel itu bisa diakses/diubah siapa saja yang punya anon key (yang notabene ada di kode frontend, jadi bukan rahasia)
- Penamaan policy: `{role/scope}_{action}_{scope}`, deskriptif — `users_select_own_orders`, `admin_select_all_orders`, `vendor_update_own_menus` — bukan nama generik seperti `policy1`
- Tabel yang **hanya** diakses dari backend sendiri (bukan langsung dari client) tetap sebaiknya RLS on dengan policy yang membatasi ke `service_role` saja, jangan andalkan "toh cuma backend yang akses" sebagai satu-satunya proteksi — defense in depth (lihat prinsip di `debug-assistant`)
- **Jangan expose `service_role` key ke frontend** — key ini bypass semua RLS, cuma boleh dipakai di server/edge function, disimpan sebagai secret (lihat bagian 8.2)
- Edge Functions (kalau dipakai) mengikuti struktur folder & error handling yang sama dengan konvensi TypeScript di bagian 2.2/5 — tetap function pendek, single responsibility, error di-throw dengan pesan jelas
- Migration schema Supabase tetap lewat file migration (`supabase migration new`, `supabase db push` ke arah yang benar — dari local ke remote lewat CI/CD terkontrol, bukan edit langsung di dashboard production) — prinsip disiplin migration di bagian 3 tetap berlaku penuh

---

## 4. Struktur Folder

### 4.1 NestJS (Modular by Feature)

```
src/
├── modules/
│   ├── user/
│   │   ├── dto/
│   │   ├── entities/
│   │   ├── user.controller.ts
│   │   ├── user.service.ts
│   │   ├── user.module.ts
│   │   └── user.repository.ts
├── common/
│   ├── decorators/ filters/ guards/ interceptors/ pipes/
├── config/
└── main.ts
```
Aturan: 1 modul = 1 domain/fitur (bukan 1 tabel). Controller tidak boleh berisi business logic — hanya orkestrasi. Business logic wajib di Service, akses DB via Repository. DTO wajib pakai `class-validator`.

### 4.2 Laravel

```
app/
├── Http/Controllers/
├── Http/Requests/     # Form Request untuk validasi
├── Http/Resources/    # API Resource untuk response shaping
├── Services/
├── Actions/            # single-purpose action class (opsional)
├── Repositories/
├── Models/
└── Exceptions/
```
Aturan: controller tetap tipis (thin controller, fat service). Validasi wajib pakai Form Request. Response API konsisten pakai API Resource, jangan return Model mentah.

### 4.3 Vue.js
```
src/
├── components/common/     # reusable
├── components/features/   # per-fitur
├── composables/
├── views/ (atau pages/)
├── stores/                 # Pinia
├── services/                # API call layer
└── utils/
```

### 4.4 Next.js (App Router)
```
app/
├── (auth)/login/ register/
├── dashboard/_components/  # private folder khusus halaman ini
components/                  # shared global
lib/                          # utils, api client, helpers
hooks/
types/
```

### 4.5 Golang (Gin/Fiber) — Layered Structure

```
cmd/
└── api/
    └── main.go                 # entry point, setup router & dependency injection

internal/
├── handler/                    # HTTP handler (setara controller) — parse request, call service, return response
│   └── order_handler.go
├── service/                    # business logic
│   └── order_service.go
├── repository/                 # akses database (GORM/sqlx), interface + implementasi
│   ├── order_repository.go
│   └── order_repository_interface.go
├── model/                      # struct entity (lihat naming di 2.4)
│   └── order.go
├── middleware/                 # auth, logging, CORS, recovery
│   └── auth_middleware.go
├── dto/                        # request/response struct (bukan entity langsung)
│   ├── create_order_request.go
│   └── order_response.go
├── response/                    # helper response envelope (Success/Error/SuccessWithPagination), lihat bagian 6.2
│   └── response.go
└── config/                     # konfigurasi env, database connection

pkg/                            # kode reusable lintas project (kalau ada)
migrations/                     # file migration (golang-migrate/goose)
```

**Aturan:**
- `internal/` dipakai untuk semua kode yang spesifik ke project ini — Go compiler mencegah package `internal/` diimpor dari luar module, ini fitur bahasa yang wajib dimanfaatkan (bukan sekadar konvensi)
- Handler **tidak boleh** berisi business logic atau akses database langsung — hanya bind request, panggil service, format response
- Repository wajib berupa interface + implementasi terpisah, supaya bisa di-mock untuk testing
- DTO (request/response) dipisah dari model/entity — jangan expose struct database langsung sebagai response API, meskipun field-nya kebetulan sama (lihat aturan field parity di 2.4/2.5, tapi tetap disiplin pisahkan layer-nya untuk fleksibilitas validasi/dokumentasi)

**Routing dengan versioning (Gin), konsisten dengan bagian 6.1:**
```go
func SetupRouter(h *handler.OrderHandler) *gin.Engine {
    r := gin.Default()
    v1 := r.Group("/api/v1")
    {
        orders := v1.Group("/orders")
        orders.GET("", h.GetOrders)
        orders.GET("/:id", h.GetOrderByID)
        orders.POST("", h.CreateOrder)
    }
    return r
}
```

---

## 5. Function & Method Standards

- Max ~30-40 baris per function. Kalau lebih, pertimbangkan dipecah.
- Single Responsibility — 1 fungsi 1 tugas. Kalau nama butuh kata "dan" (`saveAndSendEmail`), pertimbangkan dipecah.
- Max 3-4 parameter — lebih dari itu gunakan object/DTO.
- Return type eksplisit untuk public method/service (khusus TypeScript).
- Error handling: jangan silent-catch (`catch {}` kosong). Gunakan custom exception deskriptif, ditangani di layer filter/handler.

Contoh:
```typescript
// ❌ Kurang baik
async function getUser(id) {
  const user = await this.repo.find(id);
  return user;
}

// ✅ Baik
async function getUserById(id: string): Promise<UserResponseDto> {
  const user = await this.userRepository.findById(id);
  if (!user) {
    throw new NotFoundException(`User with id ${id} not found`);
  }
  return UserMapper.toDto(user);
}
```

**Golang — error handling idiomatik (return error, jangan panic untuk expected error):**
```go
// ❌ Kurang baik — error ditelan diam-diam
func GetOrderByID(id string) *Order {
    order, _ := repo.FindByID(id)
    return order
}

// ✅ Baik — error di-wrap dengan konteks, sentinel error untuk kasus spesifik
var ErrOrderNotFound = errors.New("order not found")

func (s *OrderService) GetOrderByID(ctx context.Context, id string) (*Order, error) {
    order, err := s.repo.FindByID(ctx, id)
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrOrderNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("failed to get order %s: %w", id, err)
    }
    return order, nil
}
```
- `panic` hanya untuk error yang benar-benar tidak boleh terjadi (programmer error), bukan untuk expected error seperti "data tidak ditemukan"
- Handler yang menerima error dari service memetakan ke HTTP status code yang sesuai (`errors.Is(err, ErrOrderNotFound)` → 404), bukan generic 500 untuk semua error

### 5.1 Test-Driven Development (TDD)

Untuk logic yang punya aturan bisnis nontrivial (kalkulasi, validasi bercabang, state machine seperti status order) — **tulis test dulu sebelum implementasi**, bukan sebaliknya. Untuk kode sederhana (CRUD tanpa logic khusus, passthrough), TDD boleh dilewati — pakai judgment, jangan dipaksakan ke semua baris kode.

**Siklus RED → GREEN → REFACTOR:**
1. **RED** — tulis test untuk perilaku yang diinginkan, jalankan, pastikan **gagal** (kalau test langsung lulus tanpa implementasi, test-nya tidak menguji apa-apa — perbaiki dulu)
2. **GREEN** — tulis kode **paling minimal** supaya test lulus, jangan sekalian menambah fitur lain yang belum ada test-nya (YAGNI — *You Aren't Gonna Need It*)
3. **REFACTOR** — rapikan kode setelah test hijau (naming, duplikasi, struktur), jalankan ulang test tiap kali refactor untuk pastikan masih lulus

```typescript
// 1. RED — test dulu, belum ada implementasi calculateExcessAmount
it('should return 0 excess when subsidy covers full meal price', () => {
  expect(calculateExcessAmount({ mealPrice: 15000, subsidyAmount: 15000 })).toBe(0);
});
it('should return the gap when subsidy is less than meal price', () => {
  expect(calculateExcessAmount({ mealPrice: 15000, subsidyAmount: 10000 })).toBe(5000);
});

// 2. GREEN — implementasi minimal
function calculateExcessAmount({ mealPrice, subsidyAmount }: { mealPrice: number; subsidyAmount: number }): number {
  return Math.max(0, mealPrice - subsidyAmount);
}

// 3. REFACTOR — kalau perlu rapikan lebih lanjut, test di atas jadi jaring pengaman
```

**Aturan tambahan:**
- Kalau menulis kode duluan lalu sadar butuh test, tulis test-nya lalu **pastikan test itu bisa gagal** kalau logic-nya salah (revert sementara implementasi, cek test merah, baru kembalikan) — test yang tidak pernah terbukti bisa gagal tidak bisa dipercaya
- Test mengikuti struktur folder di bagian 4 (co-locate `*.spec.ts`/`*_test.go` di sebelah file yang diuji, atau folder `tests/` sesuai konvensi framework)
- Satu test = satu perilaku yang diverifikasi — jangan gabung banyak assertion tidak terkait dalam satu test yang namanya generik

### 5.2 Quality Gates — Urutan Wajib, Jangan Lompat Tahap

Sebelum kode dianggap "selesai", jalankan berurutan — **kalau satu tahap gagal, berhenti dan perbaiki di tahap itu, jangan lanjut ke tahap berikutnya**:

```
1. Type check  →  2. Lint  →  3. Test  →  4. Review (manual/self-review)
```

**Anti-pattern yang wajib dihindari — jangan pernah "memperbaiki" test yang gagal dengan mengubah test-nya supaya lulus, kecuali memang terbukti test-nya yang salah** (bukan implementasinya). Kalau test gagal:
1. Baca kenapa gagal — apakah implementasi salah, atau ekspektasi di test yang salah?
2. Kalau implementasi yang salah → perbaiki implementasi, test tetap
3. Kalau memang test-nya salah (ekspektasi keliru) → boleh diubah, tapi **jelaskan alasannya** (di commit message atau komentar), jangan diam-diam diubah supaya cepat hijau

Contoh anti-pattern yang harus dihindari:
```typescript
// ❌ Test awalnya expect(result).toBe(150000), gagal karena bug di kalkulasi
// Lalu "diperbaiki" dengan mengubah expected value supaya cocok dengan output yang salah:
expect(result).toBe(145000);  // <- ini nutup bug, bukan nemuin bug
```
Kalau nilai yang diharapkan berubah karena requirement memang berubah, itu sah — bedanya ada di alasan perubahannya, bukan sekadar "biar lulus".

### 5.3 Simplify Pass — Setelah Fitur Jalan

Setelah implementasi lulus test dan quality gates, ada tahap terpisah untuk merapikan kode **tanpa mengubah perilakunya**:
- Sasaran: nested ternary yang membingungkan, function yang melakukan lebih dari satu hal, logic yang terlalu padat/sulit dibaca sekali lihat, abstraksi yang masuk akal saat ditulis tapi sekarang membingungkan
- **Aturan ketat: hanya boleh mengubah *cara* perilaku diekspresikan, tidak boleh mengubah perilakunya.** Kalau simplify pass butuh mengubah logic/hasil, itu bukan simplify lagi — itu perubahan fungsional yang butuh test baru/diperbarui
- Jalankan ulang test setelah simplify pass untuk pastikan masih hijau — kalau ada test yang gagal setelah "sekadar merapikan", berarti perilakunya kebawa berubah, itu bug baru yang harus diperbaiki, bukan tanda test-nya perlu disesuaikan
- Tidak perlu dilakukan untuk kode sepele; paling berguna untuk logic yang ditulis cepat saat awal implementasi dan belum sempat dirapikan

### 5.4 Logging: Error Log vs Audit Log

Dua konsep beda yang sering tercampur — pisahkan dengan jelas karena tujuan, isi, dan siapa yang membaca beda:

| | **Error Log** | **Audit Log** |
|---|---|---|
| Tujuan | Debugging — kenapa sistem gagal/error | Traceability — siapa melakukan apa, kapan, untuk kebutuhan compliance/investigasi |
| Isi | Stack trace, request context, pesan error teknis | Aktor, aksi, entity yang terdampak, nilai sebelum/sesudah |
| Retensi | Biasanya pendek (rolling/beberapa minggu), volume tinggi | Panjang/permanen, volume lebih terkontrol |
| Siapa baca | Developer saat debugging | Admin/GA/audit/compliance saat investigasi |
| Contoh | "NullPointerException di OrderService.calculateTotal, line 42" | "User `usr-123` (GA) mengubah `subsidy_amount` karyawan `usr-456` dari 10000 ke 15000 pada 2026-08-11 10:30" |

#### Error Log

**Structured logging wajib** — bukan `console.log`/`fmt.Println` string bebas, supaya bisa di-query dan di-filter di log aggregator (kalau ada):

```typescript
// NestJS — pakai logger service (winston/pino), bukan console.log
this.logger.error('Failed to process order', {
  orderId: order.id,
  userId: order.user_id,
  error: err.message,
  stack: err.stack,
});
```
```go
// Golang — structured logger (zerolog/zap), bukan fmt.Println
logger.Error().
    Str("order_id", orderID).
    Str("user_id", userID).
    Err(err).
    Msg("failed to process order")
```

**Level log** dipakai konsisten sesuai tingkat keparahan:
- `debug` — detail teknis untuk development, tidak aktif di production (atau di-filter)
- `info` — event normal yang berguna untuk trace alur (request masuk, job selesai)
- `warn` — sesuatu yang tidak ideal tapi sistem masih jalan (retry, fallback ke default)
- `error` — operasi gagal, butuh perhatian tapi sistem masih hidup
- `fatal`/`panic` — sistem tidak bisa lanjut, biasanya diikuti crash/restart

**Wajib disertakan di tiap log error:** context yang cukup untuk reproduce tanpa harus tanya balik ke user — `request_id`/`trace_id` (untuk korelasi antar log di request yang sama), `user_id` kalau relevan, endpoint/operasi yang gagal, pesan error asli.

**Jangan pernah log data sensitif:** password (meski hashed), token/API key, nomor kartu kredit lengkap, data pribadi yang tidak perlu (NIK lengkap, dll) — masking/redact kalau field itu perlu muncul di log untuk konteks (`user_id` boleh, `user.password_hash` tidak boleh).

#### Audit Log

Dibutuhkan untuk aksi yang **mengubah data penting** dan perlu bisa ditelusuri siapa yang bertanggung jawab — terutama untuk aksi admin/privileged yang mengubah data milik orang lain (contoh dari pola PRD SmartCatering: GA mengubah `subsidy_amount` karyawan, Super Admin toggle fitur RFID).

**Kapan wajib ada audit log** (bukan semua aksi butuh, jangan berlebihan):
- Perubahan data finansial/subsidi/pricing oleh admin
- Perubahan konfigurasi sistem yang berdampak luas (toggle fitur, ubah aturan bisnis global)
- Aksi privileged yang mengubah data milik user lain (admin edit/hapus data user)
- Login/akses ke data sensitif (kalau relevan untuk compliance)

**Tabel audit log — mengikuti konvensi database di bagian 2.5:**
```
audit_logs
├── id (PK)
├── actor_id        (FK ke users — siapa yang melakukan aksi)
├── action           (string — "update_subsidy", "toggle_rfid", "delete_user", dst — konsisten snake_case)
├── entity_type       (string — "user", "catering_settings", dst — nama tabel yang terdampak)
├── entity_id          (uuid — id row yang terdampak)
├── before_value        (jsonb, nullable — state sebelum perubahan)
├── after_value          (jsonb, nullable — state sesudah perubahan)
├── ip_address            (nullable)
├── created_at
```
- `before_value`/`after_value` cukup simpan field yang berubah, tidak perlu seluruh row kalau row-nya besar
- Audit log **tidak pernah di-update atau di-delete** setelah dibuat (append-only) — kalau perlu koreksi, buat entry baru, jangan edit entry lama (integritas audit trail rusak kalau bisa diubah)
- Penulisan audit log dilakukan di layer service (setelah aksi berhasil), bukan di controller/handler — supaya konsisten meskipun ada banyak entry point yang memicu aksi yang sama

---

## 6. API Design Standard

### 6.1 URL Prefix & Versioning

**Wajib** semua endpoint pakai prefix `/api` + versi eksplisit:
```
/api/v1/orders
/api/v1/orders/:orderId/items
/api/v2/orders          ← breaking change, versi baru
```

Aturan:
- Prefix `/api/v{n}` di depan **semua** route, tanpa terkecuali — jangan ada endpoint tanpa versi (`/orders` polos tidak boleh)
- Mulai dari `v1`, naikkan versi (`v2`, `v3`, ...) **hanya** kalau ada breaking change (ubah struktur response, hapus/ubah field wajib, ubah perilaku endpoint yang sudah dipakai konsumen)
- Penambahan field baru yang backward-compatible atau endpoint baru **tidak** perlu naikkan versi
- Endpoint versi lama tetap jalan selama masih ada konsumen aktif — jangan langsung hapus, deprecate dulu dan beri jangka waktu migrasi
- Tandai endpoint yang sudah deprecated di dokumentasi Swagger/OpenAPI (`@ApiOperation({ deprecated: true })` di NestJS)

**Setup di NestJS** (global prefix + versioning):
```typescript
// main.ts
app.setGlobalPrefix('api');
app.enableVersioning({
  type: VersioningType.URI,   // hasil: /api/v1/...
  defaultVersion: '1',
});
```
```typescript
@Controller({ path: 'orders', version: '1' })
export class OrderController { }
```

**Setup di Laravel** (route prefix + group per versi):
```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::apiResource('orders', OrderController::class);
});

Route::prefix('v2')->group(function () {
    Route::apiResource('orders', OrderV2Controller::class);
});
```
Base URL Laravel otomatis dapat prefix `/api` dari `RouteServiceProvider`, tinggal tambahkan prefix versi di atas.

### 6.2 Response Format (konsisten di semua endpoint & semua versi)

**Field di dalam `data` wajib snake_case, sama persis dengan nama kolom database/entity (bagian 2.2)** — tidak ada transformasi ke camelCase di response API.

**Response untuk single object/create/update:**
```json
{
  "success": true,
  "message": "Order created successfully",
  "statusCode": 201,
  "data": {
    "id": "ord-uuid-123",
    "order_code": "ORD-20260809-001",
    "user_id": "usr-uuid-456",
    "status": "pending",
    "total_amount": 150000,
    "created_at": "2026-08-09T07:30:00Z",
    "items": [
      { "id": "itm-1", "order_id": "ord-uuid-123", "product_id": "prod-001", "quantity": 2 }
    ]
  }
}
```

**Response untuk list dengan pagination — struktur `meta.pagination` wajib persis seperti ini:**
```json
{
  "success": true,
  "message": "success",
  "statusCode": 200,
  "data": [
    {
      "id": "564f68bf-b088-430f-a7d2-b3069bfbf224",
      "so_number": "SO32773",
      "status": "WAITING_APPROVAL",
      "created_at": "2026-08-11T09:18:48.239Z",
      "customer": {
        "id": "b58ec07d-a56f-48d8-9362-66b29af0af11",
        "name": "Nurmanita Putri",
        "code": "CS00911"
      },
      "total_items": 1
    }
  ],
  "meta": {
    "pagination": {
      "total": 288,
      "per_page": 10,
      "current_page": 1,
      "last_page": 29,
      "from": 1,
      "to": 10
    }
  }
}
```

**Field `meta.pagination` wajib lengkap 6 field ini, jangan sebagian:**
| Field | Arti |
|---|---|
| `total` | Total keseluruhan row yang match filter (bukan cuma yang di halaman ini) |
| `per_page` | Jumlah item per halaman (dari query param `limit`/`per_page`) |
| `current_page` | Halaman yang sedang ditampilkan |
| `last_page` | Halaman terakhir yang tersedia (`ceil(total / per_page)`) |
| `from` | Nomor urut item pertama di halaman ini (untuk halaman kosong, `null`) |
| `to` | Nomor urut item terakhir di halaman ini (untuk halaman kosong, `null`) |

**Relasi nested (`customer`, dsb) di dalam item list** — sertakan hanya field yang relevan untuk ditampilkan di list (`id`, `name`, `code`), bukan seluruh object relasi. Detail lengkap relasi diambil lewat endpoint detail (`GET /api/v1/orders/:id`), bukan digelembungkan di response list.

**Error:**
```json
{
  "success": false,
  "message": "Validation failed",
  "statusCode": 400,
  "errors": [{ "field": "email", "message": "Email is required" }]
}
```

**Aturan:**
- `statusCode` di body **selalu sama** dengan HTTP status code response-nya (jangan sampai `statusCode: 200` di body tapi HTTP status-nya sebenarnya 400) — field ini redundan secara teknis tapi memudahkan konsumen yang baca body tanpa cek header
- `message` untuk sukses boleh generik (`"success"`) untuk `GET`, tapi sebaiknya deskriptif untuk aksi yang mengubah data (`"Order created successfully"`) — konsumen sering pakai ini langsung sebagai notifikasi ke user
- `meta` **hanya muncul kalau relevan** (list/pagination) — endpoint single object/create/update tidak perlu `meta` kosong
- Semua field response (termasuk di dalam `meta.pagination`) tetap snake_case, konsisten dengan bagian 2.2

#### Implementasi Golang/Gin — Wajib Sama Persis

Format response ini **wajib sama di semua stack, termasuk Golang** — bukan cuma standar untuk NestJS/Laravel. Buat response helper terpusat di `internal/delivery/response/`, jangan susun `gin.H{...}` manual berulang di tiap handler:

```go
// internal/delivery/response/response.go
package response

import "github.com/gin-gonic/gin"

type Envelope struct {
    Success    bool        `json:"success"`
    Message    string      `json:"message"`
    StatusCode int         `json:"statusCode"`
    Data       interface{} `json:"data,omitempty"`
    Meta       *Meta       `json:"meta,omitempty"`
    Errors     interface{} `json:"errors,omitempty"`
}

type Meta struct {
    Pagination *Pagination `json:"pagination,omitempty"`
}

type Pagination struct {
    Total       int64 `json:"total"`
    PerPage     int   `json:"per_page"`
    CurrentPage int   `json:"current_page"`
    LastPage    int   `json:"last_page"`
    From        *int  `json:"from"`
    To          *int  `json:"to"`
}

func Success(c *gin.Context, statusCode int, message string, data interface{}) {
    c.JSON(statusCode, Envelope{Success: true, Message: message, StatusCode: statusCode, Data: data})
}

func SuccessWithPagination(c *gin.Context, message string, data interface{}, total int64, perPage, currentPage int) {
    lastPage := int((total + int64(perPage) - 1) / int64(perPage))
    var from, to *int
    if total > 0 {
        f := (currentPage-1)*perPage + 1
        t := f + perPage - 1
        if t > int(total) {
            t = int(total)
        }
        from, to = &f, &t
    }
    c.JSON(200, Envelope{
        Success: true, Message: message, StatusCode: 200, Data: data,
        Meta: &Meta{Pagination: &Pagination{
            Total: total, PerPage: perPage, CurrentPage: currentPage, LastPage: lastPage, From: from, To: to,
        }},
    })
}

func Error(c *gin.Context, statusCode int, message string, errors interface{}) {
    c.JSON(statusCode, Envelope{Success: false, Message: message, StatusCode: statusCode, Errors: errors})
}
```

**Pemakaian di handler:**
```go
// GET /api/v1/orders (list dengan pagination)
func (h *OrderHandler) GetOrders(c *gin.Context) {
    orders, total, err := h.service.GetOrders(c.Request.Context(), filters)
    if err != nil {
        response.Error(c, 500, "Internal server error", nil)
        return
    }
    response.SuccessWithPagination(c, "success", orders, total, perPage, currentPage)
}

// POST /api/v1/orders (create)
func (h *OrderHandler) CreateOrder(c *gin.Context) {
    var dto dto.CreateOrderRequest
    if err := c.ShouldBindJSON(&dto); err != nil {
        response.Error(c, 400, "Bad request", []map[string]string{{"field": "body", "message": err.Error()}})
        return
    }
    order, err := h.service.CreateOrder(c.Request.Context(), dto)
    if errors.Is(err, ErrProductNotFound) {
        response.Error(c, 404, "Product not found", nil)
        return
    }
    if err != nil {
        response.Error(c, 500, "Internal server error", nil)
        return
    }
    response.Success(c, 201, "Order created successfully", order)
}
```

**Aturan:**
- Handler **tidak boleh** susun `gin.H{}` manual — selalu lewat helper `response.Success`/`response.SuccessWithPagination`/`response.Error`, supaya struktur response tidak pernah menyimpang antar endpoint/antar developer
- `Data`, `Meta`, `Errors` pakai `omitempty` supaya field yang tidak relevan tidak muncul kosong di response
- Struct `Order`/DTO yang di-pass ke `Data` sudah punya json tag snake_case sesuai bagian 2.4, jadi tidak perlu transformasi tambahan di response layer
- `from`/`to` pakai pointer (`*int`) supaya bisa `null` di JSON saat total data 0 (halaman kosong), bukan `0` yang ambigu (lihat bagian 5.4 soal idiom nullable Golang)

### 6.3 Endpoint Naming

Noun, plural, kebab-case: `GET /api/v1/orders`, `POST /api/v1/order-items`. Hindari verb di URL. Nested resource: `GET /api/v1/orders/:orderId/items`.

### 6.4 HTTP Status Code

200 (sukses GET/PUT/PATCH), 201 (create), 204 (delete tanpa body), 400/422 (validasi salah), 401 (belum login), 403 (tidak punya akses), 404 (tidak ditemukan), 500 (server error).

### 6.5 Query Parameter untuk Multi-Field Filtering

Karena field API sama persis dengan field entity/database, **query parameter filter juga wajib pakai nama field snake_case yang sama** — supaya bisa langsung diteruskan ke `where` clause ORM tanpa mapping.

```
GET /api/v1/orders?status=pending&user_id=usr-uuid-456&total_amount_gte=100000
GET /api/v1/orders?items.product_id=prod-001          ← filter lewat relasi, dot notation
GET /api/v1/orders?sort=-created_at&page=1&limit=20    ← sorting & pagination
```

Konvensi operator untuk filter selain exact-match (opsional, sesuaikan kebutuhan endpoint):
| Suffix | Arti | Contoh |
|---|---|---|
| `_gte` / `_lte` | lebih besar/kecil sama dengan | `total_amount_gte=100000` |
| `_gt` / `_lt` | lebih besar/kecil dari | `created_at_gt=2026-01-01` |
| `_like` | partial match/search | `order_code_like=ORD-2026` |
| `_in` | daftar nilai (comma-separated) | `status_in=pending,paid` |
| `relation.field` | filter lewat relasi (dot notation) | `items.product_id=prod-001` |

Endpoint yang mendukung filter kompleks **wajib didokumentasikan** di Swagger/OpenAPI (lihat skill `api-doc-standard`) — sebutkan field mana saja yang bisa difilter dan operator apa yang didukung, supaya konsumen API (termasuk frontend kamu sendiri) tahu tanpa buka kode backend.

---

## 7. Frontend: State Management Standard (Vue.js & Next.js)

**Aturan utama: komponen/halaman TIDAK BOLEH memanggil API secara langsung** (fetch/axios langsung di dalam component atau page). Semua komunikasi ke backend wajib melalui layer state management, dengan alur:

```
Component/Page → Store/Query Hook → API Service Layer → Backend
```

> **Field passthrough:** Karena response API sudah snake_case sama persis dengan entity/database (bagian 6.2), **tidak perlu ada layer transformasi camelCase↔snake_case** di service layer atau store. Data dari API dipakai apa adanya. Ini menyederhanakan 3 layer di bawah — service dan store cukup pass-through data, tidak perlu mapping function tambahan.

### 7.1 Kenapa

- Komponen jadi susah di-test kalau bercampur dengan network call
- Data yang sama dipanggil ulang-ulang dari komponen berbeda tanpa caching
- Loading/error state tersebar tidak konsisten di tiap komponen
- Sulit tracking state global (misal data user yang dipakai di banyak halaman)

### 7.2 Struktur Layer (wajib 3 layer, jangan lompat layer)

**1. API Service Layer** — hanya berisi fungsi HTTP call, tidak ada state, tidak ada transformasi field
```typescript
// services/order.service.ts
// Type Order di sini field-nya snake_case, sama persis dengan response API
export const orderService = {
  getOrders: (params: OrderQueryParams) => apiClient.get<ApiResponse<Order[]>>('/api/v1/orders', { params }),
  getOrderById: (id: string) => apiClient.get<ApiResponse<Order>>(`/api/v1/orders/${id}`),
  createOrder: (payload: CreateOrderPayload) => apiClient.post<ApiResponse<Order>>('/api/v1/orders', payload),
};
```

**2. State Management Layer** — di sinilah pemanggilan service terjadi, bukan di komponen

*Vue.js — Pinia:*
```typescript
// stores/order.store.ts
export const useOrderStore = defineStore('order', {
  state: () => ({ orders: [] as Order[], loading: false, error: null as string | null }),
  actions: {
    async fetchOrders(params: OrderQueryParams) {
      this.loading = true;
      try {
        const { data } = await orderService.getOrders(params);
        this.orders = data.data;   // langsung assign, field sudah sesuai (snake_case)
      } catch (e) {
        this.error = 'Failed to fetch orders';
      } finally {
        this.loading = false;
      }
    },
  },
});
```

*Next.js — TanStack Query (direkomendasikan) atau Zustand untuk client state:*
```typescript
// hooks/use-orders.ts
export function useOrders(params: OrderQueryParams) {
  return useQuery({
    queryKey: ['orders', params],
    queryFn: () => orderService.getOrders(params).then((res) => res.data.data),
  });
}
```

**3. Component/Page Layer** — hanya konsumsi state, tidak tahu-menahu soal HTTP
```vue
<!-- Vue: komponen cukup panggil store, akses field langsung snake_case -->
<script setup>
const orderStore = useOrderStore();
onMounted(() => orderStore.fetchOrders({ page: 1 }));
</script>
<template>
  <div v-for="order in orderStore.orders" :key="order.id">
    {{ order.order_code }} — {{ order.total_amount }}
  </div>
</template>
```
```tsx
// Next.js: komponen cukup panggil hook, akses field langsung snake_case
function OrderList() {
  const { data: orders, isLoading } = useOrders({ page: 1 });
  return orders?.map((o) => <div key={o.id}>{o.order_code} — {o.total_amount}</div>);
}
```

> **Catatan untuk project Next.js dengan Server Actions:** kalau memakai App Router Server Actions (bukan API service + client-side fetching), Server Action tetap berperan sebagai "service layer" — ambil/kirim data ke backend di dalam Server Action, komponen tetap tidak langsung `fetch()` sendiri. Field yang dikembalikan dari Server Action tetap ikuti field snake_case yang sama.

### 7.3 Aturan Tambahan

- **Server state** (data dari API) vs **client state** (UI state seperti modal terbuka/tertutup, filter form) ditangani terpisah — jangan campur keduanya dalam satu store besar
  - Next.js: server state → TanStack Query atau Server Actions, client state → Zustand/`useState`
  - Vue: server state & client state boleh sama-sama di Pinia, tapi pisahkan store-nya per domain (`useOrderStore`, `useUiStore`)
- Loading, error, dan empty state wajib ditangani di layer state management, komponen tinggal render berdasarkan state yang sudah ada
- **Field dari API tidak boleh diubah namanya** di store/hook (misal jangan diam-diam ganti `total_amount` jadi `totalAmount`) — kalau butuh nama tampilan berbeda di UI, itu dilakukan di level render/computed, bukan mengubah shape data di store
- Satu service function = satu endpoint, jangan gabung beberapa call API jadi satu fungsi besar yang susah di-reuse

### 7.4 Urutan Prioritas Performance (React/Next.js & Vue)

Kalau ada masalah performance, **perbaiki sesuai urutan dampak, jangan langsung lompat ke micro-optimization.** Kesalahan paling umum: langsung pasang `useMemo`/`React.memo`/`computed` di mana-mana padahal bottleneck sebenarnya ada di tempat lain yang dampaknya jauh lebih besar.

**Urutan diagnosa (dari dampak terbesar ke terkecil):**
1. **Request waterfall** — beberapa API call yang seharusnya bisa paralel malah dipanggil berurutan (call B menunggu call A selesai padahal tidak saling bergantung). Ini biasanya penyebab terbesar halaman terasa lambat, dan paling sering luput karena tidak error, cuma lambat.
   - Next.js: gunakan `Promise.all()` untuk fetch paralel, atau Suspense boundary untuk streaming per bagian tanpa saling blocking
   - Vue: `Promise.all()` di composable, atau paralel-kan pemanggilan beberapa store action
2. **Bundle size** — cek apakah ada barrel import yang menarik seluruh library padahal cuma butuh satu fungsi/komponen (`import { Icon } from 'huge-icon-library'` yang ternyata nge-bundle semua icon). Gunakan `next/dynamic` (Next.js) atau `defineAsyncComponent` (Vue) untuk komponen berat yang tidak perlu dimuat di initial load.
3. **Data fetching pattern** — N+1 query (lihat bagian 3), fetch data yang tidak dipakai, fetch ulang data yang sudah ada di cache
4. **Re-render tidak perlu** — baru di titik ini pertimbangkan `useMemo`/`React.memo`/Vue `computed`, dan hanya di komponen yang benar-benar terbukti re-render berlebihan (profil dulu, jangan tebak-tebak pasang memoization di semua tempat)
5. **Rendering/JS execution** — optimasi list panjang (virtualization, `content-visibility: auto`), lazy load gambar

**Prinsip:** kalau belum profiling/mengukur di mana bottleneck sebenarnya, jangan langsung "optimasi" yang paling gampang dipikirkan (biasanya `useMemo`) — itu sering menambah kompleksitas tanpa menyelesaikan masalah nyata.

### 7.5 Composition Pattern — Hindari "Boolean Prop Hell"

Komponen dengan banyak boolean prop yang saling terkait (`isCompact`, `showHeader`, `isRounded`, `hasBorder`, `isHighlighted` numpuk di satu komponen) susah dipahami, di-test, dan di-extend. Pakai pola yang lebih scalable:

**Varian eksplisit, bukan boolean flag untuk mode yang saling eksklusif:**
```typescript
// ❌ Boolean prop menumpuk
<Alert isDestructive isCompact showIcon={false} />

// ✅ Varian eksplisit
<Alert.Destructive compact />
```

**Compound component untuk struktur yang punya beberapa bagian terkait:**
```tsx
// ❌ Semua konfigurasi lewat props di satu komponen
<Select
  options={options}
  showSearch
  triggerLabel="Pilih menu"
  contentMaxHeight={300}
/>

// ✅ Compound component — tiap bagian komponen terpisah tapi terkait lewat context
<Select>
  <Select.Trigger>Pilih menu</Select.Trigger>
  <Select.Content maxHeight={300}>
    <Select.Search />
    {options.map(o => <Select.Item key={o.id} value={o.id}>{o.label}</Select.Item>)}
  </Select.Content>
</Select>
```

**Kapan dipakai:** komponen reusable/shared (dipakai di banyak tempat, terutama kalau lagi bangun design system atau komponen di project seperti Proyatim yang bakal dipakai berulang) baru worth pola ini. Untuk komponen sekali pakai/spesifik satu halaman, boolean prop sederhana masih oke — jangan over-engineer komponen kecil yang tidak akan berkembang variasinya.

---

## 8. Git & Commit Convention

### 8.1 Branch & Commit

Branch: `feature/order-checkout-flow`, `fix/user-login-null-pointer`, `hotfix/payment-webhook-timeout`, `refactor/order-service-cleanup`

Commit (Conventional Commits): `<type>: <deskripsi singkat, present tense>`
Tipe: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`

### 8.2 Environment & Secrets

- **`.env` tidak pernah di-commit** — wajib ada di `.gitignore` sejak commit pertama project. Kalau project sudah terlanjur commit `.env`, hapus dari history (`git filter-repo`/BFG) dan **rotate semua secret yang sempat ke-expose**, jangan cuma dihapus dari commit terbaru (masih ada di history git).
- **Selalu sertakan `.env.example`** di-commit ke repo — isinya nama variable yang dibutuhkan dengan value placeholder/dummy (`DATABASE_URL=postgres://user:pass@localhost:5432/dbname`), supaya orang lain (atau diri sendiri 6 bulan kemudian) tahu env var apa saja yang perlu diisi tanpa harus menebak dari kode.
- **Secret di CI/CD dan production** disimpan di secret manager platform (GitHub Actions secrets, Vercel/Railway env vars, dll), bukan hardcoded di file config yang ikut ter-commit.
- **Rotasi secret** setelah: ada anggota tim yang keluar dan sempat punya akses, ada indikasi kebocoran (log ke-expose, screenshot ke-share tidak sengaja), atau secara berkala untuk kredensial sensitif (payment gateway, service-to-service key) sesuai kebijakan yang wajar untuk skala project.
- Untuk kredensial yang dipakai lintas sistem (contoh pola `X-Service-Key` di integrasi antar backend) — simpan di `.env` masing-masing sistem, jangan hardcode di kode meskipun "cuma internal".

### 8.3 Changelog

Untuk project yang punya rilis/versi yang perlu dikomunikasikan (dipakai user lain, dirilis ke production secara berkala, atau open source) — generate `CHANGELOG.md` dari histori commit, bukan ditulis manual dari ingatan:

- Karena commit sudah mengikuti Conventional Commits (8.1), changelog bisa di-generate otomatis (`conventional-changelog`, `git-cliff`, atau built-in changelog generator dari platform seperti GitHub Releases) — kelompokkan otomatis per tipe (`feat` → "Features", `fix` → "Bug Fixes", dst)
- Commit dengan `BREAKING CHANGE:` di footer atau `!` setelah tipe (`feat!:`) ditandai jelas di changelog sebagai breaking — selaras dengan checklist breaking change di `api-doc-standard`
- Untuk project kecil/internal yang tidak dirilis ke pihak luar, changelog opsional — tidak perlu dipaksakan kalau tidak ada yang membacanya

---

## 9. Checklist Code Review (pakai sebagai acuan saat review)

**Naming & Struktur**
- [ ] Nama variable/function/class sesuai konvensi di bagian 2
- [ ] File diletakkan di folder yang sesuai struktur di bagian 4
- [ ] Tidak ada logic bisnis nyasar di controller/component

**Database**
- [ ] Nama tabel plural snake_case, nama field sesuai konvensi bagian 2.5
- [ ] Primary key pakai UUID (bukan auto-increment integer), kecuali ada alasan eksplisit untuk menyimpang
- [ ] Tabel yang datanya bisa diubah user punya `created_by`/`updated_by` (nullable), bukan cuma `created_at`/`updated_at`
- [ ] FK dinamai `{singular_table}_id` dan mengarah ke tabel yang benar
- [ ] Ada index untuk FK dan kolom yang sering di-filter
- [ ] Relasi many-to-many lewat pivot table, bukan array/JSON kolom
- [ ] Migration reversible (ada `down()`/rollback yang benar)
- [ ] Kalau pakai Prisma: field model **snake_case langsung** (bukan camelCase + `@map`), hanya nama tabel yang pakai `@@map`, tidak ada query di dalam loop (N+1), transaksi multi-step pakai `$transaction`
- [ ] Kalau pakai TypeORM: field entity **snake_case langsung** (bukan camelCase + `@Column({ name })`), `@Entity('nama_tabel')` eksplisit, `synchronize: true` tidak dipakai di production
- [ ] Kalau pakai Golang (GORM/sqlx): struct field PascalCase dengan tag `json`/`db`/`gorm:"column:"` snake_case yang konsisten satu sama lain, `TableName()` eksplisit, tidak pakai `AutoMigrate()` di production, error di-wrap dengan `%w` bukan ditelan (`_`)

**Konsistensi**
- [ ] Endpoint pakai prefix `/api/v{n}`, tidak ada route tanpa versi
- [ ] Kalau ada breaking change di response/behavior, sudah naikkan versi API (bukan ubah endpoint versi lama secara langsung)
- [ ] **Field response API snake_case, identik dengan field entity/database** — tidak ada transformasi ke camelCase di controller/resource (bagian 6.2)
- [ ] Kalau Golang: response pakai helper `response.Success`/`response.Error`/`response.SuccessWithPagination`, bukan `gin.H{}` manual yang formatnya bisa menyimpang antar handler
- [ ] Query parameter filter pakai nama field yang sama dengan kolom database (bagian 6.5)
- [ ] Error handling sesuai pola yang disepakati
- [ ] Penamaan endpoint sesuai konvensi REST

**Frontend (Vue/Next.js)**
- [ ] Tidak ada pemanggilan API langsung di component/page (fetch/axios inline) — wajib lewat store/query hook
- [ ] Ada API service layer terpisah, bukan URL/endpoint ditulis langsung di store/hook
- [ ] **Tidak ada mapping/rename field API di service/store** (misal `total_amount` diam-diam diubah jadi `totalAmount`) — field dipakai apa adanya
- [ ] Server state (data API) dan client state (UI state) dipisah, tidak dicampur dalam satu store
- [ ] Loading/error/empty state ditangani di layer state management, bukan logic tersebar di komponen
- [ ] Kalau ada isu performance yang ditangani, sudah dicek request waterfall/bundle size dulu sebelum pasang `useMemo`/`computed` di semua tempat
- [ ] Komponen shared/reusable tidak menumpuk terlalu banyak boolean prop — pertimbangkan compound component/varian eksplisit kalau sudah >4-5 boolean prop saling terkait

**Scope Perubahan**
- [ ] PR/perubahan cuma menyentuh yang diminta task — tidak ada reformat/refactor kosmetik yang menumpang tanpa diminta
- [ ] Kalau ada asumsi yang diambil karena requirement ambigu, asumsinya disebutkan eksplisit (komentar/PR description), bukan diam-diam dipilih

**Kualitas Kode**
- [ ] Function tidak terlalu panjang/kompleks (>40 baris → curigai)
- [ ] Tidak ada magic number/string tanpa constant
- [ ] Tidak ada kode duplikat yang seharusnya di-reuse
- [ ] Tidak ada `console.log`/`dd()`/`var_dump()` tertinggal — pakai structured logger sesuai bagian 5.4
- [ ] Tidak ada data sensitif (password, token, data pribadi lengkap) yang ke-log
- [ ] Aksi privileged yang mengubah data penting (subsidi, konfigurasi sistem, data user lain) tercatat di audit log, bukan cuma error log
- [ ] Tidak ada hardcoded credentials/API key/token
- [ ] Kalau pakai Supabase dan tabel diakses dari client: RLS aktif dengan policy eksplisit, bukan default terbuka
- [ ] Ada `.env.example` yang up to date kalau ada env var baru ditambahkan
- [ ] Logic bisnis nontrivial (kalkulasi, validasi bercabang, state machine) punya test — bukan cuma "sudah dicoba manual sekali"
- [ ] Kalau ada test yang tadinya gagal, dipastikan penyebabnya diperbaiki di implementasi (bukan angka/ekspektasi di test yang diam-diam disesuaikan supaya lulus)
- [ ] Kalau ini PR refactor besar, ada rencana yang diikuti (bukan perubahan ad-hoc di tengah jalan tanpa arah jelas)
- [ ] Migration schema tidak destruktif tanpa strategi bertahap (kalau menyentuh tabel yang sudah ada data production)

Beri feedback dengan label: `[blocking]` (wajib diperbaiki), `[nit]` (opsional), `[question]` (klarifikasi).

---

## Catatan

Ini adalah standar hidup. Kalau ada keputusan yang menyimpang dari standar ini karena alasan teknis tertentu, dokumentasikan alasannya di komentar kode.
