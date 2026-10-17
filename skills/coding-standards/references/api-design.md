# Coding Standards — API Design

> Part of the `coding-standards` skill. Section numbers are kept so references like "section 6.2" stay valid.

## 6. API Design Standard

### 6.1 URL Prefix & Versioning

**Required**: every endpoint uses the `/api` prefix + an explicit version:
```
/api/v1/orders
/api/v1/orders/:orderId/items
/api/v2/orders          ← breaking change, new version
```

Rules:
- Prefix `/api/v{n}` in front of **every** route, no exceptions — no unversioned endpoints (plain `/orders` is not allowed)
- Start at `v1`; bump the version (`v2`, `v3`, ...) **only** for a breaking change (changed response structure, removed/changed required field, changed behavior of an endpoint consumers already use)
- Adding backward-compatible fields or new endpoints does **not** need a version bump
- Old-version endpoints keep running while there are active consumers — don't delete immediately; deprecate first and give a migration window
- Mark deprecated endpoints in the Swagger/OpenAPI docs (`@ApiOperation({ deprecated: true })` in NestJS)

**NestJS setup** (global prefix + versioning):
```typescript
// main.ts
app.setGlobalPrefix('api');
app.enableVersioning({
  type: VersioningType.URI,   // result: /api/v1/...
  defaultVersion: '1',
});
```
```typescript
@Controller({ path: 'orders', version: '1' })
export class OrderController { }
```

**Laravel setup** (route prefix + group per version):
```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::apiResource('orders', OrderController::class);
});

Route::prefix('v2')->group(function () {
    Route::apiResource('orders', OrderV2Controller::class);
});
```
Laravel's base URL gets the `/api` prefix automatically from `RouteServiceProvider`; just add the version prefix above.

### 6.2 Response Format (consistent across all endpoints & all versions)

**Fields inside `data` must be snake_case, exactly matching the database/entity column names (section 2.2)** — no camelCase transformation in API responses.

**Response for single object/create/update:**
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

**Response for a paginated list — the `meta.pagination` structure must be exactly this:**
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

**`meta.pagination` must contain all 6 fields, never a subset:**
| Field | Meaning |
|---|---|
| `total` | Total rows matching the filter (not just this page) |
| `per_page` | Items per page (from query param `limit`/`per_page`) |
| `current_page` | Page currently shown |
| `last_page` | Last available page (`ceil(total / per_page)`) |
| `from` | Sequence number of the first item on this page (`null` for an empty page) |
| `to` | Sequence number of the last item on this page (`null` for an empty page) |

**Nested relations (`customer`, etc.) inside list items** — include only fields relevant for list display (`id`, `name`, `code`), not the whole relation object. Full relation details come from the detail endpoint (`GET /api/v1/orders/:id`), not bloated into the list response.

**Error:**
```json
{
  "success": false,
  "message": "Validation failed",
  "statusCode": 400,
  "errors": [{ "field": "email", "message": "Email is required" }]
}
```

**Rules:**
- `statusCode` in the body **always equals** the response's HTTP status code (never `statusCode: 200` in the body while the actual HTTP status is 400) — technically redundant, but helps consumers who read the body without checking headers
- Success `message` may be generic (`"success"`) for `GET`, but should be descriptive for data-changing actions (`"Order created successfully"`) — consumers often show it directly as a user notification
- `meta` **appears only when relevant** (list/pagination) — single object/create/update endpoints don't need an empty `meta`
- All response fields (including inside `meta.pagination`) stay snake_case, consistent with section 2.2

#### Golang/Gin Implementation — Must Be Identical

This response format is **required on every stack, including Golang** — not just a NestJS/Laravel standard. Create a central response helper in `internal/delivery/response/`; don't build `gin.H{...}` manually in every handler:

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

**Usage in a handler:**
```go
// GET /api/v1/orders (paginated list)
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

**Rules:**
- Handlers **must not** build `gin.H{}` manually — always go through `response.Success`/`response.SuccessWithPagination`/`response.Error`, so the response structure never drifts between endpoints/developers
- `Data`, `Meta`, `Errors` use `omitempty` so irrelevant fields don't appear empty in the response
- The `Order` struct/DTO passed to `Data` already has snake_case json tags per section 2.4, so no extra transformation is needed in the response layer
- `from`/`to` use pointers (`*int`) so they can be `null` in JSON when total is 0 (empty page), not an ambiguous `0` (see section 5.4 on the Golang nullable idiom)

### 6.3 Endpoint Naming

Noun, plural, kebab-case: `GET /api/v1/orders`, `POST /api/v1/order-items`. Avoid verbs in URLs. Nested resource: `GET /api/v1/orders/:orderId/items`.

### 6.4 HTTP Status Code

200 (successful GET/PUT/PATCH), 201 (create), 204 (delete with no body), 400/422 (validation error), 401 (not logged in), 403 (no access), 404 (not found), 500 (server error).

### 6.5 Query Parameters for Multi-Field Filtering

Since API fields exactly match entity/database fields, **filter query parameters must also use the same snake_case field names** — so they can be passed straight into the ORM `where` clause without mapping.

```
GET /api/v1/orders?status=pending&user_id=usr-uuid-456&total_amount_gte=100000
GET /api/v1/orders?items.product_id=prod-001          ← filter via relation, dot notation
GET /api/v1/orders?sort=-created_at&page=1&limit=20    ← sorting & pagination
```

Operator convention for non-exact-match filters (optional, adapt to the endpoint's needs):
| Suffix | Meaning | Example |
|---|---|---|
| `_gte` / `_lte` | greater/less than or equal | `total_amount_gte=100000` |
| `_gt` / `_lt` | greater/less than | `created_at_gt=2026-01-01` |
| `_like` | partial match/search | `order_code_like=ORD-2026` |
| `_in` | list of values (comma-separated) | `status_in=pending,paid` |
| `relation.field` | filter via relation (dot notation) | `items.product_id=prod-001` |

Endpoints supporting complex filters **must be documented** in Swagger/OpenAPI (see `references/api-doc.md`) — list which fields are filterable and which operators are supported, so API consumers (including your own frontend) know without opening the backend code.
