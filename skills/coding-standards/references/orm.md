# Coding Standards — ORM & Database Access

> Bagian dari skill `coding-standards`. Nomor bagian dipertahankan supaya rujukan seperti "bagian 3.1" tetap valid.

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
