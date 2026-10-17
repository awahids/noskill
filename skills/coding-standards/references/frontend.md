# Coding Standards — Frontend State Management

> Part of the `coding-standards` skill. Section numbers are kept so references like "section 7.2" stay valid.

## 7. Frontend: State Management Standard (Vue.js & Next.js)

**Core rule: components/pages MUST NOT call the API directly** (no fetch/axios inside a component or page). All backend communication must go through the state management layer, following:

```
Component/Page → Store/Query Hook → API Service Layer → Backend
```

> **Field passthrough:** Since API responses are already snake_case, identical to the entity/database (section 6.2), **no camelCase↔snake_case transformation layer is needed** in the service layer or store. API data is used as is. This simplifies the 3 layers below — service and store just pass data through, no extra mapping functions.

### 7.1 Why

- Components become hard to test when mixed with network calls
- The same data gets fetched repeatedly from different components without caching
- Loading/error state is scattered and inconsistent across components
- Global state is hard to track (e.g. user data used on many pages)

### 7.2 Layer Structure (3 layers required, never skip a layer)

**1. API Service Layer** — only HTTP call functions, no state, no field transformation
```typescript
// services/order.service.ts
// The Order type here uses snake_case fields, identical to the API response
export const orderService = {
  getOrders: (params: OrderQueryParams) => apiClient.get<ApiResponse<Order[]>>('/api/v1/orders', { params }),
  getOrderById: (id: string) => apiClient.get<ApiResponse<Order>>(`/api/v1/orders/${id}`),
  createOrder: (payload: CreateOrderPayload) => apiClient.post<ApiResponse<Order>>('/api/v1/orders', payload),
};
```

**2. State Management Layer** — service calls happen here, not in components

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
        this.orders = data.data;   // assign directly, fields already match (snake_case)
      } catch (e) {
        this.error = 'Failed to fetch orders';
      } finally {
        this.loading = false;
      }
    },
  },
});
```

*Next.js — TanStack Query (recommended) or Zustand for client state:*
```typescript
// hooks/use-orders.ts
export function useOrders(params: OrderQueryParams) {
  return useQuery({
    queryKey: ['orders', params],
    queryFn: () => orderService.getOrders(params).then((res) => res.data.data),
  });
}
```

**3. Component/Page Layer** — only consumes state, knows nothing about HTTP
```vue
<!-- Vue: the component just calls the store, accesses snake_case fields directly -->
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
// Next.js: the component just calls the hook, accesses snake_case fields directly
function OrderList() {
  const { data: orders, isLoading } = useOrders({ page: 1 });
  return orders?.map((o) => <div key={o.id}>{o.order_code} — {o.total_amount}</div>);
}
```

> **Note for Next.js projects with Server Actions:** if you use App Router Server Actions (instead of an API service + client-side fetching), the Server Action still acts as the "service layer" — fetch/send backend data inside the Server Action; components still never call `fetch()` themselves. Fields returned from a Server Action still follow the same snake_case fields.

### 7.3 Additional Rules

- **Server state** (API data) and **client state** (UI state like modal open/closed, form filters) are handled separately — don't mix them in one big store
  - Next.js: server state → TanStack Query or Server Actions, client state → Zustand/`useState`
  - Vue: server and client state may both live in Pinia, but split stores per domain (`useOrderStore`, `useUiStore`)
- Loading, error, and empty states must be handled in the state management layer; components just render based on existing state
- **API field names must not be changed** in the store/hook (e.g. don't silently rename `total_amount` to `totalAmount`) — if the UI needs a different display name, do it at render/computed level, not by changing the data shape in the store
- One service function = one endpoint; don't merge several API calls into one big function that's hard to reuse

### 7.4 Performance Priority Order (React/Next.js & Vue)

For performance problems, **fix in order of impact; don't jump straight to micro-optimization.** The most common mistake: sprinkling `useMemo`/`React.memo`/`computed` everywhere while the real bottleneck is elsewhere with far bigger impact.

**Diagnosis order (largest to smallest impact):**
1. **Request waterfall** — several API calls that could run in parallel are called sequentially (call B waits for call A though they're independent). This is usually the biggest cause of a slow-feeling page, and the most often missed because it doesn't error, it's just slow.
   - Next.js: use `Promise.all()` for parallel fetches, or Suspense boundaries to stream sections without blocking each other
   - Vue: `Promise.all()` in a composable, or parallelize multiple store action calls
2. **Bundle size** — check for barrel imports that pull in a whole library when only one function/component is needed (`import { Icon } from 'huge-icon-library'` that turns out to bundle every icon). Use `next/dynamic` (Next.js) or `defineAsyncComponent` (Vue) for heavy components not needed on initial load.
3. **Data fetching pattern** — N+1 queries (see section 3), fetching unused data, refetching data already in cache
4. **Unnecessary re-renders** — only at this point consider `useMemo`/`React.memo`/Vue `computed`, and only in components proven to re-render excessively (profile first; don't guess and add memoization everywhere)
5. **Rendering/JS execution** — optimize long lists (virtualization, `content-visibility: auto`), lazy-load images

**Principle:** if you haven't profiled/measured where the real bottleneck is, don't immediately apply the easiest-to-think-of "optimization" (usually `useMemo`) — it often adds complexity without solving the real problem.

### 7.5 Composition Pattern — Avoid "Boolean Prop Hell"

Components with many interrelated boolean props (`isCompact`, `showHeader`, `isRounded`, `hasBorder`, `isHighlighted` piling up on one component) are hard to understand, test, and extend. Use more scalable patterns:

**Explicit variants, not boolean flags, for mutually exclusive modes:**
```typescript
// ❌ Piled-up boolean props
<Alert isDestructive isCompact showIcon={false} />

// ✅ Explicit variant
<Alert.Destructive compact />
```

**Compound components for structures with several related parts:**
```tsx
// ❌ All configuration through props on one component
<Select
  options={options}
  showSearch
  triggerLabel="Pilih menu"
  contentMaxHeight={300}
/>

// ✅ Compound component — each part is a separate component, linked via context
<Select>
  <Select.Trigger>Pilih menu</Select.Trigger>
  <Select.Content maxHeight={300}>
    <Select.Search />
    {options.map(o => <Select.Item key={o.id} value={o.id}>{o.label}</Select.Item>)}
  </Select.Content>
</Select>
```

**When to use:** only worth it for reusable/shared components (used in many places, especially when building a design system or components that will be reused repeatedly). For one-off/page-specific components, simple boolean props are still fine — don't over-engineer small components whose variations won't grow.
