# Coding Standards — Struktur Folder

> Bagian dari skill `coding-standards`. Nomor bagian dipertahankan supaya rujukan seperti "bagian 4.5" tetap valid.

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
