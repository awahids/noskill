# Coding Standards — API Design

> Bagian dari skill `coding-standards`. Nomor bagian dipertahankan supaya rujukan seperti "bagian 6.2" tetap valid.

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
