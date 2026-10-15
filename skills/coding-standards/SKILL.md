---
name: coding-standards
description: >-
  Standar kode lengkap untuk NestJS, Laravel, Golang/Gin, Vue, Next.js, dan PostgreSQL/MySQL: naming, struktur folder, ORM & migration, format response API, state management, TDD, quality gates, dan checklist code review. Gunakan saat membuat project/modul/endpoint/migration baru, melakukan code review, atau user menyebut "sesuai standar", "naming", "struktur folder".
---

# Coding Standards — Acuan Penulisan & Review Kode

Skill ini adalah standar coding pribadi/tim untuk stack: **NestJS, Laravel, Golang/Gin, Vue.js, Next.js, TypeScript, PHP, PostgreSQL/MySQL**.

Gunakan standar ini SETIAP KALI:
- Menulis kode baru (function, class, component, endpoint, migration)
- Membuat file atau folder baru
- Melakukan code review (jadikan checklist di bagian akhir sebagai acuan)
- Mendesain struktur API/response

Jika stack yang dipakai user berbeda dari yang tercakup di sini, tetap terapkan **prinsip umum** (bagian 1 & 2.1) dan sesuaikan secara wajar.

---

## 1. Prinsip Umum

1. Konsistensi lebih penting daripada preferensi pribadi — ikuti standar ini meskipun ada cara lain yang valid.
2. Readability first — kode dibaca jauh lebih sering daripada ditulis.
3. Explicit lebih baik daripada implicit — hindari "magic" yang bikin orang lain menebak.
4. **Reuse dulu, DRY tapi jangan over-abstract.**
   - Sebelum menulis logic baru, cari dulu di codebase (grep nama fungsi/konsep terkait). Kalau sudah ada helper/service yang melakukan hal yang sama, pakai itu — jangan menulis versi kedua.
   - Logic bisnis ditaruh di layer yang bisa dipakai ulang dan dites (service/usecase/`lib`), bukan di dalam controller, handler, atau komponen UI. UI/controller cukup memanggil.
   - Duplikasi 2x masih oke; baru ekstrak jadi fungsi bersama di duplikasi ke-3. Jangan bikin abstraksi "biar reusable nanti" untuk kode yang baru dipakai sekali.
5. Fail fast, fail loud — validasi input di awal, jangan biarkan error menyebar diam-diam.
6. **Refactor besar butuh rencana dulu, bukan langsung diubah.** Untuk refactor yang menyentuh banyak file/mengubah struktur (bukan sekadar rename kecil atau simplify pass di bagian 5.3), tulis dulu rencana step-by-step sebelum menyentuh kode: apa yang diubah, urutan langkahnya, bagaimana memverifikasi tiap langkah tidak merusak yang sudah jalan. Refactor tanpa rencana punya risiko besar memperbaiki satu hal sambil merusak hal lain yang tidak diperhatikan — terutama berbahaya di logic yang sudah dipakai production. Rencana ini bisa singkat (bullet list) untuk refactor kecil, atau lebih detail (mirip task breakdown di skill `task-breakdown`) untuk refactor besar lintas modul.
7. **Surgical changes — sentuh cuma yang diminta.** Kalau task-nya "perbaiki bug X", jangan sekalian reformat file, ganti gaya penulisan, atau "membenahi" kode di sekitarnya yang tidak diminta — meskipun menurut penilaian sendiri itu lebih baik. Perubahan yang tidak diminta bikin diff susah direview (perubahan penting tenggelam di antara perubahan kosmetik) dan berisiko mengubah perilaku yang tidak dimaksud. Kalau ketemu kode di sekitarnya yang jelas bermasalah tapi di luar scope task, **sebutkan** ke user sebagai catatan terpisah — jangan langsung diubah tanpa diminta. Simplify pass (5.3) dan refactor terencana (poin 6) adalah pengecualian sah karena memang itu tujuannya, tapi tetap sebagai task tersendiri yang eksplisit, bukan menumpang di task lain.
8. **Nyatakan asumsi secara eksplisit, jangan diam-diam pilih satu.** Kalau requirement/instruksi punya lebih dari satu interpretasi yang masuk akal, sebutkan interpretasi mana yang dipakai dan kenapa — jangan langsung jalan dengan satu asumsi tanpa bilang. Ini beda dari "selalu bertanya dulu": untuk hal yang bisa diputuskan dengan asumsi wajar, tetap jalan, tapi asumsinya ditulis eksplisit (misal di komentar, di ringkasan awal jawaban, atau di PR description) supaya user bisa koreksi kalau asumsinya salah, alih-alih ketahuan salah setelah kode sudah jauh berjalan.
9. **Solusi paling sederhana dulu.** Sebelum menulis kode, pikirkan dulu caranya, lalu ambil opsi pertama yang sudah menyelesaikan masalah secara lengkap:
   1. Apakah perlu dibuat sama sekali? Jangan tambah fitur, opsi, atau fleksibilitas yang tidak diminta.
   2. Sudah ada di codebase (helper, service, komponen, pola)? Pakai itu dengan cara yang sama seperti kode di sekitarnya.
   3. Ada di standard library atau fitur framework? Pakai itu.
   4. Ada di dependency yang sudah terpasang? Pakai itu. Jangan tambah dependency baru untuk beberapa baris kode.
   5. Kalau tetap harus ditulis: kode seminimal mungkin yang benar, tanpa abstraksi, wrapper, config, atau kode "buat nanti" yang tidak dibutuhkan sekarang.

   Sederhana bukan berarti asal: validasi input di batas sistem, error handling yang mencegah data rusak, dan keamanan tidak boleh dipangkas. Dari dua solusi yang sama-sama sederhana, pilih yang benar untuk edge case.

---

## 2. Naming Convention

### 2.1 Umum (berlaku semua bahasa)

| Elemen | Konvensi | Contoh |
|---|---|---|
| Boolean | Prefix `is`, `has`, `can`, `should` | `isActive`, `hasPermission`, `canEdit` |
| Function/Method | Kata kerja + objek | `getUserById()`, `calculateTotalPrice()` |
| Event handler | Prefix `on` / `handle` | `onSubmit`, `handleClick` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Private/internal | Prefix `_` (jika bahasa tidak punya `private` native) | `_calculateInternal()` |

Hindari: nama generik (`data`, `temp`, `obj`), singkatan tidak jelas (`usr`, `qty`), nama yang menyesatkan (fungsi `getUser` yang juga menghapus data).

### 2.2–2.5 Per Stack & Database

**Baca [`references/naming.md`](references/naming.md) sebelum** membuat file, class, struct, tabel, kolom, atau migration baru: 2.2 TypeScript/JavaScript, 2.3 PHP, 2.4 Golang, 2.5 database (tabel, kolom, kolom wajib, relasi, index).

Ringkasan yang selalu berlaku: tabel snake_case jamak bahasa Inggris (`order_items`), PK `id` bertipe UUID, FK `{tabel_singular}_id`, kolom wajib `created_by`/`updated_by`/`created_at`/`updated_at`/`deleted_at`, dan field JSON di response API snake_case sama persis dengan kolom database.

---

## 3. ORM & Database Access Standard (Node.js & Golang)

**Baca [`references/orm.md`](references/orm.md) sebelum** menulis schema/model, query, atau migration. Isinya: disiplin migration production, Prisma v7+ (`prisma-client` generator, `prisma.config.ts`), TypeORM, kapan pilih Prisma vs TypeORM, GORM/sqlx untuk Golang, dan Supabase.

Ringkasan yang selalu berlaku: satu ORM/query approach per service, schema production hanya berubah lewat file migration yang di-commit (bukan `db push`/`AutoMigrate()`/`synchronize: true`), dan perubahan destruktif dilakukan bertahap (nullable → backfill → constraint).

---

## 4. Struktur Folder

**Baca [`references/folder-structure.md`](references/folder-structure.md) sebelum** membuat project baru, modul baru, atau file di lokasi yang belum pernah dipakai. Isinya: 4.1 NestJS (modular by feature), 4.2 Laravel, 4.3 Vue.js, 4.4 Next.js App Router, 4.5 Golang layered structure.

Kalau project sudah punya struktur sendiri, ikuti struktur existing — referensi ini untuk project baru.

---

## 5. Function & Method Standards

- Max ~30-40 baris per function. Kalau lebih, pertimbangkan dipecah.
- Single Responsibility — 1 fungsi 1 tugas. Kalau nama butuh kata "dan" (`saveAndSendEmail`), pertimbangkan dipecah.
- Max 3-4 parameter — lebih dari itu gunakan object/DTO.
- Return type eksplisit untuk public method/service (khusus TypeScript).
- Error handling: jangan silent-catch (`catch {}` kosong). Gunakan custom exception deskriptif, ditangani di layer filter/handler.

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

### 5.1 Test-Driven Development (TDD)

Untuk logic yang punya aturan bisnis nontrivial (kalkulasi, validasi bercabang, state machine seperti status order) — **tulis test dulu sebelum implementasi**, bukan sebaliknya. Untuk kode sederhana (CRUD tanpa logic khusus, passthrough), TDD boleh dilewati — pakai judgment, jangan dipaksakan ke semua baris kode.

**Siklus RED → GREEN → REFACTOR:**
1. **RED** — tulis test untuk perilaku yang diinginkan, jalankan, pastikan **gagal** (kalau test langsung lulus tanpa implementasi, test-nya tidak menguji apa-apa — perbaiki dulu)
2. **GREEN** — tulis kode **paling minimal** supaya test lulus, jangan sekalian menambah fitur lain yang belum ada test-nya (YAGNI — *You Aren't Gonna Need It*)
3. **REFACTOR** — rapikan kode setelah test hijau (naming, duplikasi, struktur), jalankan ulang test tiap kali refactor untuk pastikan masih lulus

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

**Aturan tambahan:**
- Kalau menulis kode duluan lalu sadar butuh test, tulis test-nya lalu **pastikan test itu bisa gagal** kalau logic-nya salah (revert sementara implementasi, cek test merah, baru kembalikan) — test yang tidak pernah terbukti bisa gagal tidak bisa dipercaya
- Test mengikuti struktur folder di bagian 4 (co-locate `*.spec.ts`/`*_test.go` di sebelah file yang diuji, atau folder `tests/` sesuai konvensi framework)
- Satu test = satu perilaku yang diverifikasi — jangan gabung banyak assertion tidak terkait dalam satu test yang namanya generik
- **Wajib test positif dan negatif** untuk setiap aturan bisnis:
  - **Positif** — input valid menghasilkan hasil yang benar (happy path)
  - **Negatif** — input tidak valid / kondisi terlarang ditolak dengan benar (error yang tepat, data tidak berubah)
  - **Batas** — nilai tepat di batas aturan dan satu langkah di luarnya (misal `= 90%` dan `89,99%`), karena bug paling sering ada di sana
  - Nama test menyebut jenisnya supaya mudah dicek, misal `rejects quantity above outstanding` (negatif) dan `accepts quantity equal to outstanding` (batas)

### 5.2 Quality Gates — Urutan Wajib, Jangan Lompat Tahap

Sebelum kode dianggap "selesai", jalankan berurutan — **kalau satu tahap gagal, berhenti dan perbaiki di tahap itu, jangan lanjut ke tahap berikutnya**:

```
1. Type check  →  2. Lint  →  3. Test  →  4. Review (manual/self-review)
```

**Anti-pattern yang wajib dihindari — jangan pernah "memperbaiki" test yang gagal dengan mengubah test-nya supaya lulus, kecuali memang terbukti test-nya yang salah** (bukan implementasinya). Kalau test gagal:
1. Baca kenapa gagal — apakah implementasi salah, atau ekspektasi di test yang salah?
2. Kalau implementasi yang salah → perbaiki implementasi, test tetap
3. Kalau memang test-nya salah (ekspektasi keliru) → boleh diubah, tapi **jelaskan alasannya** (di commit message atau komentar), jangan diam-diam diubah supaya cepat hijau

Contoh anti-pattern yang harus dihindari:
```typescript
// ❌ Test awalnya expect(result).toBe(150000), gagal karena bug di kalkulasi
// Lalu "diperbaiki" dengan mengubah expected value supaya cocok dengan output yang salah:
expect(result).toBe(145000);  // <- ini nutup bug, bukan nemuin bug
```
Kalau nilai yang diharapkan berubah karena requirement memang berubah, itu sah — bedanya ada di alasan perubahannya, bukan sekadar "biar lulus".

### 5.3 Simplify Pass — Setelah Fitur Jalan

Setelah implementasi lulus test dan quality gates, ada tahap terpisah untuk merapikan kode **tanpa mengubah perilakunya**:
- Sasaran: nested ternary yang membingungkan, function yang melakukan lebih dari satu hal, logic yang terlalu padat/sulit dibaca sekali lihat, abstraksi yang masuk akal saat ditulis tapi sekarang membingungkan
- **Aturan ketat: hanya boleh mengubah *cara* perilaku diekspresikan, tidak boleh mengubah perilakunya.** Kalau simplify pass butuh mengubah logic/hasil, itu bukan simplify lagi — itu perubahan fungsional yang butuh test baru/diperbarui
- Jalankan ulang test setelah simplify pass untuk pastikan masih hijau — kalau ada test yang gagal setelah "sekadar merapikan", berarti perilakunya kebawa berubah, itu bug baru yang harus diperbaiki, bukan tanda test-nya perlu disesuaikan
- Tidak perlu dilakukan untuk kode sepele; paling berguna untuk logic yang ditulis cepat saat awal implementasi dan belum sempat dirapikan

### 5.4 Logging: Error Log vs Audit Log

Error log (untuk debugging, retensi pendek) dan audit log (siapa-ubah-apa untuk compliance, append-only, ditulis di layer service) adalah dua hal berbeda — jangan dicampur. **Baca [`references/logging.md`](references/logging.md) sebelum** menambah logging atau tabel audit: isinya perbandingan lengkap, format, dan aturan tiap jenis log.

---

## 6. API Design Standard

**Baca [`references/api-design.md`](references/api-design.md) sebelum** membuat atau mengubah endpoint. Isinya: 6.1 URL prefix & versioning, 6.2 response format (termasuk implementasi Golang/Gin yang wajib sama persis), 6.3 endpoint naming, 6.4 HTTP status code, 6.5 query parameter untuk multi-field filtering.

**Baca [`references/api-doc.md`](references/api-doc.md) sebelum** menambah atau mengubah dokumentasi Swagger/OpenAPI endpoint. Isinya: decorator/anotasi wajib per endpoint untuk NestJS (`@nestjs/swagger`), Laravel (`l5-swagger`/`scramble`), dan Golang (`swaggo`), skema response standar, setup versioning, checklist breaking change, dan checklist sebelum merge.

Ringkasan yang selalu berlaku: semua endpoint pakai prefix `/api/v{n}`, satu format response envelope yang sama di semua endpoint & versi, dan `statusCode` di body selalu sama dengan HTTP status.

---

## 7. Frontend: State Management Standard (Vue.js & Next.js)

**Baca [`references/frontend.md`](references/frontend.md) sebelum** menulis store, service API, atau komponen reusable di Vue.js/Next.js. Isinya: 7.2 struktur 3 layer (jangan lompat layer), 7.3 aturan tambahan, 7.4 prioritas performance, 7.5 composition pattern (hindari boolean prop hell).

---

## 8. Git & Commit Convention

### 8.1 Branch & Commit

Branch: `feature/order-checkout-flow`, `fix/user-login-null-pointer`, `hotfix/payment-webhook-timeout`, `refactor/order-service-cleanup`

Commit (Conventional Commits): `<type>: <deskripsi singkat, present tense>`
Tipe: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`

### 8.2 Environment & Secrets

- **`.env` tidak pernah di-commit** — wajib ada di `.gitignore` sejak commit pertama project. Kalau project sudah terlanjur commit `.env`, hapus dari history (`git filter-repo`/BFG) dan **rotate semua secret yang sempat ke-expose**, jangan cuma dihapus dari commit terbaru (masih ada di history git).
- **Selalu sertakan `.env.example`** di-commit ke repo — isinya nama variable yang dibutuhkan dengan value placeholder/dummy (`DATABASE_URL=postgres://user:pass@localhost:5432/dbname`), supaya orang lain (atau diri sendiri 6 bulan kemudian) tahu env var apa saja yang perlu diisi tanpa harus menebak dari kode.
- **Secret di CI/CD dan production** disimpan di secret manager platform (GitHub Actions secrets, Vercel/Railway env vars, dll), bukan hardcoded di file config yang ikut ter-commit.
- **Rotasi secret** setelah: ada anggota tim yang keluar dan sempat punya akses, ada indikasi kebocoran (log ke-expose, screenshot ke-share tidak sengaja), atau secara berkala untuk kredensial sensitif (payment gateway, service-to-service key) sesuai kebijakan yang wajar untuk skala project.
- Untuk kredensial yang dipakai lintas sistem (contoh pola `X-Service-Key` di integrasi antar backend) — simpan di `.env` masing-masing sistem, jangan hardcode di kode meskipun "cuma internal".

### 8.3 Changelog

Untuk project yang punya rilis/versi yang perlu dikomunikasikan (dipakai user lain, dirilis ke production secara berkala, atau open source) — generate `CHANGELOG.md` dari histori commit, bukan ditulis manual dari ingatan:

- Karena commit sudah mengikuti Conventional Commits (8.1), changelog bisa di-generate otomatis (`conventional-changelog`, `git-cliff`, atau built-in changelog generator dari platform seperti GitHub Releases) — kelompokkan otomatis per tipe (`feat` → "Features", `fix` → "Bug Fixes", dst)
- Commit dengan `BREAKING CHANGE:` di footer atau `!` setelah tipe (`feat!:`) ditandai jelas di changelog sebagai breaking — selaras dengan checklist breaking change di `references/api-doc.md`
- Untuk project kecil/internal yang tidak dirilis ke pihak luar, changelog opsional — tidak perlu dipaksakan kalau tidak ada yang membacanya

---

## 9. Checklist Code Review (pakai sebagai acuan saat review)

**Naming & Struktur**
- [ ] Nama variable/function/class sesuai konvensi di bagian 2
- [ ] File diletakkan di folder yang sesuai struktur di bagian 4
- [ ] Tidak ada logic bisnis nyasar di controller/component

**Database**
- [ ] Nama tabel plural snake_case, nama field sesuai konvensi bagian 2.5
- [ ] Primary key pakai UUID (bukan auto-increment integer), kecuali ada alasan eksplisit untuk menyimpang
- [ ] Tabel yang datanya bisa diubah user punya `created_by`/`updated_by` (nullable), bukan cuma `created_at`/`updated_at`
- [ ] FK dinamai `{singular_table}_id` dan mengarah ke tabel yang benar
- [ ] Ada index untuk FK dan kolom yang sering di-filter
- [ ] Relasi many-to-many lewat pivot table, bukan array/JSON kolom
- [ ] Migration reversible (ada `down()`/rollback yang benar)
- [ ] Kalau pakai Prisma: field model **snake_case langsung** (bukan camelCase + `@map`), hanya nama tabel yang pakai `@@map`, tidak ada query di dalam loop (N+1), transaksi multi-step pakai `$transaction`
- [ ] Kalau pakai TypeORM: field entity **snake_case langsung** (bukan camelCase + `@Column({ name })`), `@Entity('nama_tabel')` eksplisit, `synchronize: true` tidak dipakai di production
- [ ] Kalau pakai Golang (GORM/sqlx): struct field PascalCase dengan tag `json`/`db`/`gorm:"column:"` snake_case yang konsisten satu sama lain, `TableName()` eksplisit, tidak pakai `AutoMigrate()` di production, error di-wrap dengan `%w` bukan ditelan (`_`)

**Konsistensi**
- [ ] Endpoint pakai prefix `/api/v{n}`, tidak ada route tanpa versi
- [ ] Kalau ada breaking change di response/behavior, sudah naikkan versi API (bukan ubah endpoint versi lama secara langsung)
- [ ] **Field response API snake_case, identik dengan field entity/database** — tidak ada transformasi ke camelCase di controller/resource (bagian 6.2)
- [ ] Kalau Golang: response pakai helper `response.Success`/`response.Error`/`response.SuccessWithPagination`, bukan `gin.H{}` manual yang formatnya bisa menyimpang antar handler
- [ ] Query parameter filter pakai nama field yang sama dengan kolom database (bagian 6.5)
- [ ] Error handling sesuai pola yang disepakati
- [ ] Penamaan endpoint sesuai konvensi REST

**Frontend (Vue/Next.js)**
- [ ] Tidak ada pemanggilan API langsung di component/page (fetch/axios inline) — wajib lewat store/query hook
- [ ] Ada API service layer terpisah, bukan URL/endpoint ditulis langsung di store/hook
- [ ] **Tidak ada mapping/rename field API di service/store** (misal `total_amount` diam-diam diubah jadi `totalAmount`) — field dipakai apa adanya
- [ ] Server state (data API) dan client state (UI state) dipisah, tidak dicampur dalam satu store
- [ ] Loading/error/empty state ditangani di layer state management, bukan logic tersebar di komponen
- [ ] Kalau ada isu performance yang ditangani, sudah dicek request waterfall/bundle size dulu sebelum pasang `useMemo`/`computed` di semua tempat
- [ ] Komponen shared/reusable tidak menumpuk terlalu banyak boolean prop — pertimbangkan compound component/varian eksplisit kalau sudah >4-5 boolean prop saling terkait

**Scope Perubahan**
- [ ] PR/perubahan cuma menyentuh yang diminta task — tidak ada reformat/refactor kosmetik yang menumpang tanpa diminta
- [ ] Kalau ada asumsi yang diambil karena requirement ambigu, asumsinya disebutkan eksplisit (komentar/PR description), bukan diam-diam dipilih

**Kualitas Kode**
- [ ] Function tidak terlalu panjang/kompleks (>40 baris → curigai)
- [ ] Tidak ada magic number/string tanpa constant
- [ ] Tidak ada kode duplikat yang seharusnya di-reuse
- [ ] Tidak ada `console.log`/`dd()`/`var_dump()` tertinggal — pakai structured logger sesuai bagian 5.4
- [ ] Tidak ada data sensitif (password, token, data pribadi lengkap) yang ke-log
- [ ] Aksi privileged yang mengubah data penting (subsidi, konfigurasi sistem, data user lain) tercatat di audit log, bukan cuma error log
- [ ] Tidak ada hardcoded credentials/API key/token
- [ ] Kalau pakai Supabase dan tabel diakses dari client: RLS aktif dengan policy eksplisit, bukan default terbuka
- [ ] Ada `.env.example` yang up to date kalau ada env var baru ditambahkan
- [ ] Logic bisnis nontrivial (kalkulasi, validasi bercabang, state machine) punya test — bukan cuma "sudah dicoba manual sekali"
- [ ] Kalau ada test yang tadinya gagal, dipastikan penyebabnya diperbaiki di implementasi (bukan angka/ekspektasi di test yang diam-diam disesuaikan supaya lulus)
- [ ] Kalau ini PR refactor besar, ada rencana yang diikuti (bukan perubahan ad-hoc di tengah jalan tanpa arah jelas)
- [ ] Migration schema tidak destruktif tanpa strategi bertahap (kalau menyentuh tabel yang sudah ada data production)

Beri feedback dengan label: `[blocking]` (wajib diperbaiki), `[nit]` (opsional), `[question]` (klarifikasi).

---

## Catatan

Ini adalah standar hidup. Kalau ada keputusan yang menyimpang dari standar ini karena alasan teknis tertentu, dokumentasikan alasannya di komentar kode.
