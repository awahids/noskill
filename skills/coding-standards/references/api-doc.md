<!-- Part of the coding-standards skill. Read before adding or changing Swagger/OpenAPI documentation. -->
# API Documentation Standard

Use this standard whenever you create or document an API endpoint (NestJS/Laravel/Golang), so Swagger/OpenAPI docs stay consistent across services and are easy for API consumers (frontend, other teams, external clients) to understand.

## 1. Principles

- Every public/internal endpoint used by more than one consumer **must** be documented.
- Write documentation together with the code, not afterwards.
- Request/response examples must be realistic, not empty placeholders (`"string"`, `"example"`).
- Every path in the docs **must** use the `/api/v{n}` prefix per the versioning standard in `coding-standards` section 6.1 (`references/api-design.md`) — no endpoint docs without a version.

## 2. NestJS (`@nestjs/swagger`)

### Required structure per endpoint

**Every endpoint must document a request payload example AND a response example for every status code that can occur** — not just list status codes without example content. The path must also follow versioning (`/api/v1/...`).

```typescript
@ApiTags('Orders')
@Controller({ path: 'orders', version: '1' })   // resulting path: /api/v1/orders
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

**Required minimum (add other status codes if the endpoint has specific cases — e.g. 409 Conflict for duplicates, 429 Too Many Requests for rate limiting):**

| Status | When used | Payload example required? |
|---|---|---|
| 200 | GET/PUT/PATCH success | Yes — `data` example matching the real content |
| 201 | POST success (create) | Yes — example of the newly created entity including `id` |
| 204 | DELETE success with no body | No body needed, description is enough |
| 400 | Malformed request | Yes — example showing which field errored |
| 401 | Not logged in/invalid token | Yes — usually the same across endpoints, may be reused |
| 403 | No access | Yes — state the specific reason if possible (role, ownership) |
| 404 | Resource not found | Yes — state which resource was looked up |
| 409 | Conflict (e.g. duplicate data) | Yes, if the endpoint can hit this |
| 422 | Business validation failed | Yes — differs from 400: business rules, not format |
| 429 | Rate limit exceeded | Yes, if the endpoint is rate-limited |
| 500 | Unexpected server error | Yes — generic message, never expose a stack trace |

### Other rules
- `@ApiTags` per module, tag names PascalCase plural matching the domain: `Orders`, `Users`, `WarehouseStocks`
- `@ApiOperation.summary` short (< 10 words); `description` may be more detailed if business context is needed
- Every DTO field must have `@ApiProperty()` with `description` and `example`:
  ```typescript
  @ApiProperty({ description: 'Product SKU code', example: 'SKU-00123' })
  sku: string;
  ```
- Document **all** relevant non-200 status codes (400, 401, 403, 404, 422, 500)
- Optional fields use `@ApiPropertyOptional()`, not `@ApiProperty({ required: false })`

## 3. Laravel (OpenAPI via annotations / `l5-swagger` or `scramble`)

### Required structure per endpoint

Same as NestJS — **every status code must have a concrete payload/response example**, not just an empty schema declaration.

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

With Laravel Scramble (auto-generated from Form Request + Resource), Scramble reads examples automatically from:
- `rules()` in the Form Request for 422 cases — make sure custom validation messages (`messages()`) are filled in so error examples are clear, not generic
- Add a `documentation()` method/manual annotations to complete the 401/403/404/500 examples that can't be read from code automatically

### Additional rules
- Form Requests have complete `rules()` with clear data types (no `sometimes` without a reason)
- API Resources (`toArray()`) reflect the fields actually returned, not the whole raw model

## 4. Golang/Gin (`swaggo/swag`)

Same as NestJS and Laravel — **every endpoint must document a request payload example and a response example for every status code that can occur**, written as structured comments above the handler and generated into an OpenAPI spec via `swag init`.

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

**Concrete payload/response examples** — swaggo can't always infer realistic examples from the struct alone, so add `example` tags in the DTO:

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

**Project setup (once per project):**
```bash
go install github.com/swaggo/swag/cmd/swag@latest
swag init -g cmd/api/main.go -o docs/swagger
```
```go
// main.go — general project annotations, once above main()
// @title           Order API
// @version         1.0
// @BasePath        /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
```

**Rules:**
- The `@Router` tag **must** use the full path with version prefix (`/api/v1/orders`), consistent with `coding-standards` section 6.1 — never write an unversioned path in annotations
- `@Success`/`@Failure` **must** point to the DTO struct/`response.Envelope` the handler actually uses (`coding-standards` section 6.2), not a generic `{object} interface{}` — so the generated schema truly reflects the real response shape
- Every DTO field that needs a realistic example gets an `example:"..."` tag, especially fields whose format isn't obvious from the name (UUID, special code formats)
- Regenerating docs (`swag init`) is part of the build/CI step, not a manual step that's easy to forget after changing an endpoint
- Deprecated endpoints are marked with `@Deprecated` in the godoc comment

## 5. Response Schema Standard

Consistent with the response format in the `coding-standards` skill section 6.2 — `statusCode` in the body always equals the HTTP status, fields are snake_case, pagination via `meta.pagination` with all 6 fields:

```json
{
  "success": true,
  "message": "Order created successfully",
  "statusCode": 201,
  "data": { "id": "uuid", "order_code": "ORD-20260809-001", "total_amount": 150000 }
}
```

For list/pagination:
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
Document `data` as a typed object/array schema, not an empty `"type": "object"`. For list endpoints, also document the `meta.pagination` structure in the response schema.

## 6. Swagger/OpenAPI Setup for Versioning

Since every endpoint must use the `/api/v{n}` prefix (see `coding-standards` section 6.1), Swagger docs must also reflect the version correctly, not just the path.

**NestJS — `main.ts`:**
```typescript
app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });

const config = new DocumentBuilder()
  .setTitle('Order API')
  .setVersion('1.0')          // Swagger document version, keep in sync with the active API version
  .addBearerAuth()
  .build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);
```
- If `v2` runs in parallel with `v1` (transition period), consider separate Swagger docs per version (`api/docs/v1`, `api/docs/v2`) so consumers aren't confused about which endpoint is active in which version
- Endpoints that are deprecated but still alive during transition must be marked explicitly: `@ApiOperation({ summary: '...', deprecated: true })`

**Laravel — separate docs per version when using `l5-swagger`:**
```php
// config/l5-swagger.php — can have multiple documentation instances
'documentations' => [
    'v1' => [ 'api' => ['title' => 'Order API v1'], 'paths' => ['annotations' => [base_path('app/Http/Controllers/V1')]] ],
    'v2' => [ 'api' => ['title' => 'Order API v2'], 'paths' => ['annotations' => [base_path('app/Http/Controllers/V2')]] ],
],
```

## 7. Breaking Change Checklist — Before Deciding to Bump the Version

API changes are classified as **breaking** (must bump version, `v1` → `v2`) or **non-breaking** (may stay on the same version). Misclassifying toward "assume it's safe" is the most common reason API consumers (including your own frontend) suddenly break without warning.

**Counts as BREAKING (must bump version or deprecate first):**
- [ ] Removing a field from the response that existed before
- [ ] Changing a field's data type (`string` → `number`, `total_amount: 15000` → `total_amount: "15000"`)
- [ ] Renaming a field (`total_amount` → `total_price`)
- [ ] Adding a new **required** field to the request body (old consumers that don't send it will fail)
- [ ] Changing nested object structure (a flat field becomes nested, or vice versa)
- [ ] Changing a field's meaning/validation without renaming it (`status: "done"` used to mean success, now means something else)
- [ ] Changing default behavior old consumers already depend on (e.g. the default ordering of `GET` results changes)
- [ ] Removing an endpoint that is still in use

**NOT breaking (may stay on the same version):**
- [ ] Adding a **new** field to the response (old consumers that don't read it are unaffected)
- [ ] Adding a new **optional** field to the request body
- [ ] Adding a new endpoint
- [ ] Adding a new enum value, **as long as old consumers are designed to ignore unknown values** (if old consumers use a strict switch-case with no default case, this is still practically breaking even if not contractually — consider this case)
- [ ] Fixing a bug that made the previous response wrong (note: if any consumer silently depends on that bug, still communicate before fixing)

**If unsure whether it's breaking** — treat it as breaking. The cost of wrongly assuming "safe" (consumers suddenly erroring in production) is far higher than wrongly assuming "breaking" (an unnecessary version bump).

**Before merging a breaking change:**
1. Make sure the old-version endpoint keeps working (not replaced/removed immediately)
2. Mark `deprecated: true` in the old version's docs (see section 6)
3. Inform internal consumers (if other teams/projects use it) before the old version is actually shut down, and give a reasonable migration window

## 8. Pre-Merge Checklist

- [ ] All new endpoints have tag, summary, and response schema
- [ ] **Endpoint paths in the docs use the `/api/v{n}` prefix for the active version**, no unversioned paths
- [ ] All DTO/Request fields have description + example
- [ ] **Every non-200 status code that can occur (400/401/403/404/409/422/429/500) has a request payload example AND a response example**, not just the status listed
- [ ] Request/response examples use realistic data (not generic `"string"`, `"example"`)
- [ ] Possible error status codes are documented completely, with the error messages the system actually returns
- [ ] Tag names are consistent with module/domain names (check the `coding-standards` skill)
- [ ] If this endpoint replaces an old version, the old-version endpoint is marked `deprecated: true` in the docs
- [ ] Changes were checked against the Breaking Change Checklist (section 7) — if breaking, the version was bumped, not silently changed in the same version
- [ ] Docs were test-rendered in Swagger UI / `/api/docs` (NestJS/Laravel) or via `swag init` output (Golang), with no parsing errors
