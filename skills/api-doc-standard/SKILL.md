---
name: api-doc-standard
description: >-
  Standar dokumentasi Swagger/OpenAPI untuk NestJS, Laravel, dan Golang (swaggo): decorator/anotasi per endpoint, response schema, tag, dan versioning. Gunakan saat membuat atau mendokumentasikan endpoint, atau user menyebut "swagger", "openapi", "api spec", "dokumentasi endpoint".
---

# API Documentation Standard

Gunakan standar ini setiap kali membuat atau mendokumentasikan endpoint API (NestJS/Laravel/Golang), agar dokumentasi Swagger/OpenAPI konsisten antar service dan mudah dipahami konsumen API (frontend, tim lain, client eksternal).

## 1. Prinsip

- Setiap endpoint publik/internal yang dipakai lebih dari satu konsumen **wajib** didokumentasikan.
- Dokumentasi ditulis bersamaan dengan kode, bukan belakangan.
- Contoh request/response harus realistis, bukan placeholder kosong (`"string"`, `"example"`).
- Semua path di dokumentasi **wajib** mengikuti prefix `/api/v{n}` sesuai standar versioning di skill `coding-standards` bagian 6.1 — jangan ada dokumentasi endpoint tanpa versi.

## 2. NestJS (`@nestjs/swagger`)

### Struktur wajib per endpoint

**Setiap endpoint wajib mendokumentasikan contoh payload request DAN contoh response untuk setiap status code yang mungkin terjadi** — bukan cuma menyebut status code tanpa contoh isinya. Path juga wajib mengikuti versioning (`/api/v1/...`).

```typescript
@ApiTags('Orders')
@Controller({ path: 'orders', version: '1' })   // hasil path: /api/v1/orders
export class OrderController {

@ApiOperation({ summary: 'Create a new order', description: 'Creates an order and reserves stock for each item.' })
@ApiBody({
  type: CreateOrderDto,
  examples: {
    default: {
      summary: 'Contoh request order 2 item',
      value: {
        user_id: 'a1b2c3d4-uuid',
        items: [
          { product_id: 'prod-001', quantity: 2 },
          { product_id: 'prod-002', quantity: 1 },
        ],
        shipping_address: 'Jl. Industri Raya No. 10, Cikarang',
      },
    },
  },
})
@ApiResponse({
  status: 201,
  description: 'Order berhasil dibuat',
  schema: {
    example: {
      success: true,
      message: 'Order created successfully',
      statusCode: 201,
      data: {
        id: 'ord-uuid-123',
        order_code: 'ORD-20260809-001',
        status: 'pending',
        total_amount: 150000,
        created_at: '2026-08-09T07:30:00Z',
      },
    },
  },
})
@ApiResponse({
  status: 400,
  description: 'Request tidak valid (format salah)',
  schema: {
    example: {
      success: false,
      message: 'Bad request',
      statusCode: 400,
      errors: [{ field: 'items', message: 'items must not be empty' }],
    },
  },
})
@ApiResponse({
  status: 401,
  description: 'Token tidak ada atau tidak valid',
  schema: {
    example: { success: false, message: 'Unauthorized', statusCode: 401 },
  },
})
@ApiResponse({
  status: 403,
  description: 'Tidak punya izin untuk membuat order (misal role tidak sesuai)',
  schema: {
    example: { success: false, message: 'Forbidden resource', statusCode: 403 },
  },
})
@ApiResponse({
  status: 404,
  description: 'Salah satu product_id tidak ditemukan',
  schema: {
    example: {
      success: false,
      message: 'Product not found',
      statusCode: 404,
      errors: [{ field: 'items[0].product_id', message: 'Product prod-001 not found' }],
    },
  },
})
@ApiResponse({
  status: 422,
  description: 'Validasi bisnis gagal (misal stok tidak cukup)',
  schema: {
    example: { success: false, message: 'Insufficient stock for product prod-002', statusCode: 422 },
  },
})
@ApiResponse({
  status: 500,
  description: 'Kesalahan server yang tidak terduga',
  schema: {
    example: { success: false, message: 'Internal server error', statusCode: 500 },
  },
})
@Post()
createOrder(@Body() dto: CreateOrderDto): Promise<OrderResponseDto> {
  ...
}

}
```

**Wajib disertakan minimal (sesuaikan status code lain kalau endpoint punya kasus spesifik — misal 409 Conflict untuk duplikat, 429 Too Many Requests untuk rate limit):**

| Status | Kapan dipakai | Wajib contoh payload? |
|---|---|---|
| 200 | GET/PUT/PATCH sukses | Ya — contoh `data` sesuai isi sebenarnya |
| 201 | POST sukses (create) | Ya — contoh entity yang baru dibuat lengkap dengan `id` |
| 204 | DELETE sukses tanpa body | Tidak perlu body, cukup description |
| 400 | Request salah format | Ya — contoh field mana yang error |
| 401 | Belum login/token invalid | Ya — biasanya sama di semua endpoint, boleh reuse |
| 403 | Tidak punya akses | Ya — sebutkan alasan spesifik kalau bisa (role, ownership) |
| 404 | Resource tidak ditemukan | Ya — sebutkan resource mana yang dicari |
| 409 | Konflik (misal data duplikat) | Ya, kalau endpoint punya kemungkinan ini |
| 422 | Validasi bisnis gagal | Ya — beda dari 400, ini soal aturan bisnis bukan format |
| 429 | Rate limit terlampaui | Ya, kalau endpoint di-rate-limit |
| 500 | Server error tak terduga | Ya — pesan generik, jangan expose stack trace |

### Aturan lain
- `@ApiTags` per modul, nama tag PascalCase plural sesuai domain: `Orders`, `Users`, `WarehouseStocks`
- `@ApiOperation.summary` singkat (< 10 kata), `description` boleh lebih detail kalau perlu konteks bisnis
- Setiap DTO field wajib `@ApiProperty()` dengan `description` dan `example`:
  ```typescript
  @ApiProperty({ description: 'Product SKU code', example: 'SKU-00123' })
  sku: string;
  ```
- Dokumentasikan **semua** kemungkinan status code non-200 yang relevan (400, 401, 403, 404, 422, 500)
- Field opsional pakai `@ApiPropertyOptional()`, jangan `@ApiProperty({ required: false })`

## 3. Laravel (OpenAPI via anotasi / `l5-swagger` atau `scramble`)

### Struktur wajib per endpoint

Sama seperti NestJS — **setiap status code wajib punya contoh payload/response konkret**, bukan cuma deklarasi skema kosong.

```php
/**
 * @OA\Post(
 *     path="/api/v1/orders",
 *     tags={"Orders"},
 *     summary="Create a new order",
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(
 *             example={
 *                 "user_id": "a1b2c3d4-uuid",
 *                 "items": {
 *                     {"product_id": "prod-001", "quantity": 2},
 *                     {"product_id": "prod-002", "quantity": 1}
 *                 },
 *                 "shipping_address": "Jl. Industri Raya No. 10, Cikarang"
 *             }
 *         )
 *     ),
 *     @OA\Response(
 *         response=201,
 *         description="Order berhasil dibuat",
 *         @OA\JsonContent(example={
 *             "success": true,
 *             "message": "Order created successfully",
 *             "statusCode": 201,
 *             "data": {"id": "ord-uuid-123", "order_code": "ORD-20260809-001", "status": "pending", "total_amount": 150000}
 *         })
 *     ),
 *     @OA\Response(
 *         response=401,
 *         description="Token tidak valid",
 *         @OA\JsonContent(example={"success": false, "message": "Unauthenticated", "statusCode": 401})
 *     ),
 *     @OA\Response(
 *         response=403,
 *         description="Tidak punya izin",
 *         @OA\JsonContent(example={"success": false, "message": "This action is unauthorized", "statusCode": 403})
 *     ),
 *     @OA\Response(
 *         response=404,
 *         description="Product tidak ditemukan",
 *         @OA\JsonContent(example={"success": false, "message": "Product not found", "statusCode": 404})
 *     ),
 *     @OA\Response(
 *         response=422,
 *         description="Validasi gagal",
 *         @OA\JsonContent(example={
 *             "success": false,
 *             "message": "The given data was invalid.",
 *             "statusCode": 422,
 *             "errors": {"items": {"The items field is required."}}
 *         })
 *     ),
 *     @OA\Response(
 *         response=500,
 *         description="Kesalahan server",
 *         @OA\JsonContent(example={"success": false, "message": "Internal server error", "statusCode": 500})
 *     )
 * )
 */
```

Kalau pakai Laravel Scramble (auto-generate dari Form Request + Resource), Scramble otomatis membaca contoh dari:
- `rules()` di Form Request untuk kasus 422 — pastikan pesan validasi custom (`messages()`) diisi supaya contoh error jelas, bukan generik
- Tambahkan method `documentation()`/anotasi manual untuk melengkapi contoh 401/403/404/500 yang tidak otomatis terbaca dari kode

### Aturan tambahan
- Form Request punya `rules()` yang lengkap dan tipe data jelas (jangan `sometimes` tanpa alasan)
- API Resource (`toArray()`) mencerminkan field yang benar-benar dikembalikan, bukan seluruh model mentah

## 4. Golang/Gin (`swaggo/swag`)

Sama seperti NestJS dan Laravel — **setiap endpoint wajib mendokumentasikan contoh payload request dan contoh response untuk setiap status code yang mungkin terjadi**, ditulis lewat komentar terstruktur di atas handler, di-generate jadi OpenAPI spec lewat `swag init`.

```go
// CreateOrder godoc
// @Summary      Create a new order
// @Description  Creates an order and reserves stock for each item.
// @Tags         Orders
// @Accept       json
// @Produce      json
// @Param        request body dto.CreateOrderRequest true "Order payload"
// @Success      201 {object} response.Envelope{data=dto.OrderResponse} "Order berhasil dibuat"
// @Failure      400 {object} response.Envelope "Request tidak valid"
// @Failure      401 {object} response.Envelope "Token tidak ada atau tidak valid"
// @Failure      403 {object} response.Envelope "Tidak punya izin"
// @Failure      404 {object} response.Envelope "Product tidak ditemukan"
// @Failure      422 {object} response.Envelope "Validasi bisnis gagal (stok tidak cukup)"
// @Failure      500 {object} response.Envelope "Kesalahan server"
// @Router       /api/v1/orders [post]
// @Security     BearerAuth
func (h *OrderHandler) CreateOrder(c *gin.Context) {
    // ...
}
```

**Contoh payload/response konkret** — swaggo tidak selalu bisa infer contoh realistis dari struct saja, jadi lengkapi dengan tag `example` di DTO:

```go
type CreateOrderRequest struct {
    UserID string      `json:"user_id" example:"a1b2c3d4-uuid" binding:"required"`
    Items  []OrderItem `json:"items" binding:"required,min=1"`
}

type OrderItem struct {
    ProductID string `json:"product_id" example:"prod-001" binding:"required"`
    Quantity  int    `json:"quantity" example:"2" binding:"required,min=1"`
}

type OrderResponse struct {
    ID          string  `json:"id" example:"ord-uuid-123"`
    OrderCode   string  `json:"order_code" example:"ORD-20260809-001"`
    Status      string  `json:"status" example:"pending"`
    TotalAmount float64 `json:"total_amount" example:"150000"`
}
```

**Setup project (sekali per project):**
```bash
go install github.com/swaggo/swag/cmd/swag@latest
swag init -g cmd/api/main.go -o docs/swagger
```
```go
// main.go — anotasi umum project, sekali di atas main()
// @title           Order API
// @version         1.0
// @BasePath        /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
```

**Aturan:**
- Tag `@Router` **wajib** pakai path lengkap dengan prefix versi (`/api/v1/orders`), selaras dengan `coding-standards` bagian 6.1 — jangan tulis path tanpa versi di anotasi
- `@Success`/`@Failure` **wajib** mengarah ke struct DTO/`response.Envelope` yang benar-benar dipakai handler (bagian 6.2 `coding-standards`), bukan `{object} interface{}` generik — supaya schema yang di-generate benar-benar mencerminkan bentuk response asli
- Setiap field DTO yang butuh contoh realistis diberi tag `example:"..."`, terutama untuk field yang formatnya tidak jelas dari nama field saja (UUID, kode format khusus)
- Regenerasi dokumentasi (`swag init`) jadi bagian dari langkah build/CI, bukan langkah manual yang gampang lupa dijalankan setelah ubah endpoint
- Endpoint yang sudah deprecated ditandai dengan `@Deprecated` di komentar godoc

## 5. Response Schema Standard

Selaras dengan format response di skill `coding-standards` bagian 6.2 — `statusCode` di body selalu sama dengan HTTP status, field snake_case, pagination lewat `meta.pagination` dengan 6 field lengkap:

```json
{
  "success": true,
  "message": "Order created successfully",
  "statusCode": 201,
  "data": { "id": "uuid", "order_code": "ORD-20260809-001", "total_amount": 150000 }
}
```

Untuk list/pagination:
```json
{
  "success": true,
  "message": "success",
  "statusCode": 200,
  "data": [{ "id": "uuid", "order_code": "ORD-20260809-001" }],
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
Dokumentasikan `data` sebagai schema object/array bertipe, bukan `"type": "object"` kosong. Untuk endpoint list, dokumentasikan juga struktur `meta.pagination` di response schema-nya.

## 6. Setup Swagger/OpenAPI untuk Versioning

Karena semua endpoint wajib pakai prefix `/api/v{n}` (lihat `coding-standards` bagian 6.1), dokumentasi Swagger juga harus mencerminkan versi dengan benar, bukan cuma path-nya saja yang berubah.

**NestJS — `main.ts`:**
```typescript
app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });

const config = new DocumentBuilder()
  .setTitle('Order API')
  .setVersion('1.0')          // versi dokumen Swagger, selaraskan dengan versi API aktif
  .addBearerAuth()
  .build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);
```
- Kalau ada `v2` yang berjalan paralel dengan `v1` (masa transisi), pertimbangkan dokumen Swagger terpisah per versi (`api/docs/v1`, `api/docs/v2`) supaya konsumen tidak bingung endpoint mana yang aktif di versi mana
- Endpoint yang sudah deprecated tapi masih hidup untuk masa transisi wajib ditandai eksplisit: `@ApiOperation({ summary: '...', deprecated: true })`

**Laravel — pisahkan dokumentasi per versi kalau pakai `l5-swagger`:**
```php
// config/l5-swagger.php — bisa punya multiple documentation instance
'documentations' => [
    'v1' => [ 'api' => ['title' => 'Order API v1'], 'paths' => ['annotations' => [base_path('app/Http/Controllers/V1')]] ],
    'v2' => [ 'api' => ['title' => 'Order API v2'], 'paths' => ['annotations' => [base_path('app/Http/Controllers/V2')]] ],
],
```

## 7. Breaking Change Checklist — Sebelum Memutuskan Naik Versi

Perubahan API dikategorikan **breaking** (wajib naik versi, `v1` → `v2`) atau **non-breaking** (boleh tetap di versi yang sama). Salah kategorisasi ke arah "anggap aman" adalah penyebab paling umum konsumen API (termasuk frontend kamu sendiri) tiba-tiba error tanpa peringatan.

**Dihitung BREAKING (wajib naik versi atau deprecate dulu):**
- [ ] Menghapus field dari response yang sebelumnya ada
- [ ] Mengubah tipe data field (`string` → `number`, `total_amount: 15000` → `total_amount: "15000"`)
- [ ] Mengubah nama field (`total_amount` → `total_price`)
- [ ] Menambah field **required** baru di request body (konsumen lama yang tidak kirim field ini akan gagal)
- [ ] Mengubah struktur nested object (field yang tadinya flat jadi nested, atau sebaliknya)
- [ ] Mengubah makna/validasi field tanpa mengubah nama (`status: "done"` yang tadinya berarti sukses, sekarang berarti sesuatu yang lain)
- [ ] Mengubah default behavior yang konsumen lama sudah bergantung padanya (misal urutan default hasil `GET` berubah)
- [ ] Menghapus endpoint yang masih dipakai

**TIDAK breaking (boleh tetap di versi yang sama):**
- [ ] Menambah field **baru** di response (konsumen lama yang tidak baca field itu tidak terpengaruh)
- [ ] Menambah field **optional** baru di request body
- [ ] Menambah endpoint baru
- [ ] Menambah value baru di enum, **selama konsumen lama didesain untuk mengabaikan value yang tidak dikenal** (kalau konsumen lama pakai switch-case ketat tanpa default case, ini tetap berisiko breaking secara praktis meski secara kontrak API tidak — pertimbangkan kasus ini)
- [ ] Memperbaiki bug yang membuat response sebelumnya salah (dengan catatan: kalau ada konsumen yang diam-diam bergantung ke bug tersebut, tetap komunikasikan sebelum fix)

**Kalau ragu breaking atau tidak** — anggap breaking. Konsekuensi salah anggap "aman" (konsumen tiba-tiba error di production) jauh lebih mahal daripada konsekuensi salah anggap "breaking" (naik versi yang sebenarnya tidak perlu).

**Sebelum merge perubahan yang breaking:**
1. Pastikan endpoint versi lama tetap jalan (tidak langsung diganti/dihapus)
2. Tandai `deprecated: true` di dokumentasi versi lama (lihat bagian 6)
3. Informasikan ke konsumen internal (kalau ada tim/proyek lain yang pakai) sebelum versi lama benar-benar dimatikan, beri jangka waktu migrasi yang wajar

## 8. Checklist Sebelum Merge

- [ ] Semua endpoint baru punya tag, summary, dan response schema
- [ ] **Path endpoint di dokumentasi sudah pakai prefix `/api/v{n}` sesuai versi aktif**, tidak ada path tanpa versi
- [ ] Semua field DTO/Request punya description + example
- [ ] **Setiap status code non-200 yang mungkin terjadi (400/401/403/404/409/422/429/500) sudah punya contoh payload request DAN contoh response**, bukan cuma disebut statusnya saja
- [ ] Contoh request/response pakai data realistis (bukan `"string"`, `"example"` generik)
- [ ] Status code error yang mungkin terjadi sudah didokumentasikan lengkap dengan pesan error yang sebenarnya dikembalikan sistem
- [ ] Nama tag konsisten dengan nama modul/domain (cek skill `coding-standards`)
- [ ] Kalau endpoint ini menggantikan versi lama, endpoint versi lama sudah ditandai `deprecated: true` di dokumentasi
- [ ] Perubahan sudah dicek terhadap Breaking Change Checklist (bagian 7) — kalau breaking, sudah naik versi, bukan diam-diam diubah di versi yang sama
- [ ] Dokumentasi sudah dicoba render di Swagger UI / `/api/docs` (NestJS/Laravel) atau hasil `swag init` (Golang), tidak ada error parsing
