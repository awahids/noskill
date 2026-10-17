# Coding Standards — Folder Structure

> Part of the `coding-standards` skill. Section numbers are kept so references like "section 4.5" stay valid.

## 4. Folder Structure

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
Rules: 1 module = 1 domain/feature (not 1 table). Controllers must not contain business logic — orchestration only. Business logic must live in the Service, DB access via the Repository. DTOs must use `class-validator`.

### 4.2 Laravel

```
app/
├── Http/Controllers/
├── Http/Requests/     # Form Request for validation
├── Http/Resources/    # API Resource for response shaping
├── Services/
├── Actions/            # single-purpose action class (optional)
├── Repositories/
├── Models/
└── Exceptions/
```
Rules: keep controllers thin (thin controller, fat service). Validation must use Form Requests. API responses consistently use API Resources; never return a raw Model.

### 4.3 Vue.js
```
src/
├── components/common/     # reusable
├── components/features/   # per feature
├── composables/
├── views/ (or pages/)
├── stores/                 # Pinia
├── services/                # API call layer
└── utils/
```

### 4.4 Next.js (App Router)
```
app/
├── (auth)/login/ register/
├── dashboard/_components/  # private folder for this page only
components/                  # shared global
lib/                          # utils, api client, helpers
hooks/
types/
```

### 4.5 Golang (Gin/Fiber) — Layered Structure

```
cmd/
└── api/
    └── main.go                 # entry point, router setup & dependency injection

internal/
├── handler/                    # HTTP handler (controller equivalent) — parse request, call service, return response
│   └── order_handler.go
├── service/                    # business logic
│   └── order_service.go
├── repository/                 # database access (GORM/sqlx), interface + implementation
│   ├── order_repository.go
│   └── order_repository_interface.go
├── model/                      # entity structs (see naming in 2.4)
│   └── order.go
├── middleware/                 # auth, logging, CORS, recovery
│   └── auth_middleware.go
├── dto/                        # request/response structs (not entities directly)
│   ├── create_order_request.go
│   └── order_response.go
├── response/                    # response envelope helpers (Success/Error/SuccessWithPagination), see section 6.2
│   └── response.go
└── config/                     # env config, database connection

pkg/                            # code reusable across projects (if any)
migrations/                     # migration files (golang-migrate/goose)
```

**Rules:**
- `internal/` holds all code specific to this project — the Go compiler prevents `internal/` packages from being imported outside the module; this is a language feature that must be used (not just a convention)
- Handlers **must not** contain business logic or direct database access — only bind the request, call the service, format the response
- Repositories must be an interface + separate implementation, so they can be mocked for testing
- DTOs (request/response) are separate from models/entities — don't expose database structs directly as API responses, even if the fields happen to match (see the field parity rule in 2.4/2.5, but still keep the layers separate for validation/documentation flexibility)

**Routing with versioning (Gin), consistent with section 6.1:**
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
