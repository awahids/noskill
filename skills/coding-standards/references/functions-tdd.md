<!-- Bagian dari skill coding-standards: contoh kode fungsi, TDD, anti-pattern test, dan simplify pass. -->
# Coding Standards — Contoh Fungsi, TDD, dan Simplify Pass

## 5. Function & Method — contoh

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

## 5.1 TDD — contoh siklus RED → GREEN → REFACTOR

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

## 5.2 Quality Gates — anti-pattern

Contoh anti-pattern yang harus dihindari:
```typescript
// ❌ Test awalnya expect(result).toBe(150000), gagal karena bug di kalkulasi
// Lalu "diperbaiki" dengan mengubah expected value supaya cocok dengan output yang salah:
expect(result).toBe(145000);  // <- ini nutup bug, bukan nemuin bug
```
Kalau nilai yang diharapkan berubah karena requirement memang berubah, itu sah — bedanya ada di alasan perubahannya, bukan sekadar "biar lulus".

## 5.3 Simplify Pass — Setelah Fitur Jalan

Setelah implementasi lulus test dan quality gates, ada tahap terpisah untuk merapikan kode **tanpa mengubah perilakunya**:
- Sasaran: nested ternary yang membingungkan, function yang melakukan lebih dari satu hal, logic yang terlalu padat/sulit dibaca sekali lihat, abstraksi yang masuk akal saat ditulis tapi sekarang membingungkan
- **Aturan ketat: hanya boleh mengubah *cara* perilaku diekspresikan, tidak boleh mengubah perilakunya.** Kalau simplify pass butuh mengubah logic/hasil, itu bukan simplify lagi — itu perubahan fungsional yang butuh test baru/diperbarui
- Jalankan ulang test setelah simplify pass untuk pastikan masih hijau — kalau ada test yang gagal setelah "sekadar merapikan", berarti perilakunya kebawa berubah, itu bug baru yang harus diperbaiki, bukan tanda test-nya perlu disesuaikan
- Tidak perlu dilakukan untuk kode sepele; paling berguna untuk logic yang ditulis cepat saat awal implementasi dan belum sempat dirapikan
