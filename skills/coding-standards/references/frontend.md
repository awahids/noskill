# Coding Standards — Frontend State Management

> Bagian dari skill `coding-standards`. Nomor bagian dipertahankan supaya rujukan seperti "bagian 7.2" tetap valid.

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

**Kapan dipakai:** komponen reusable/shared (dipakai di banyak tempat, terutama kalau lagi bangun design system atau komponen yang bakal dipakai berulang) baru worth pola ini. Untuk komponen sekali pakai/spesifik satu halaman, boolean prop sederhana masih oke — jangan over-engineer komponen kecil yang tidak akan berkembang variasinya.
