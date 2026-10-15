# Coding Standards — Logging

> Bagian dari skill `coding-standards`. Nomor bagian dipertahankan supaya rujukan seperti "bagian 5.4" tetap valid.

### 5.4 Logging: Error Log vs Audit Log

Dua konsep beda yang sering tercampur — pisahkan dengan jelas karena tujuan, isi, dan siapa yang membaca beda:

| | **Error Log** | **Audit Log** |
|---|---|---|
| Tujuan | Debugging — kenapa sistem gagal/error | Traceability — siapa melakukan apa, kapan, untuk kebutuhan compliance/investigasi |
| Isi | Stack trace, request context, pesan error teknis | Aktor, aksi, entity yang terdampak, nilai sebelum/sesudah |
| Retensi | Biasanya pendek (rolling/beberapa minggu), volume tinggi | Panjang/permanen, volume lebih terkontrol |
| Siapa baca | Developer saat debugging | Admin/GA/audit/compliance saat investigasi |
| Contoh | "NullPointerException di OrderService.calculateTotal, line 42" | "User `usr-123` (GA) mengubah `subsidy_amount` karyawan `usr-456` dari 10000 ke 15000 pada 2026-08-11 10:30" |

#### Error Log

**Structured logging wajib** — bukan `console.log`/`fmt.Println` string bebas, supaya bisa di-query dan di-filter di log aggregator (kalau ada):

```typescript
// NestJS — pakai logger service (winston/pino), bukan console.log
this.logger.error('Failed to process order', {
  orderId: order.id,
  userId: order.user_id,
  error: err.message,
  stack: err.stack,
});
```
```go
// Golang — structured logger (zerolog/zap), bukan fmt.Println
logger.Error().
    Str("order_id", orderID).
    Str("user_id", userID).
    Err(err).
    Msg("failed to process order")
```

**Level log** dipakai konsisten sesuai tingkat keparahan:
- `debug` — detail teknis untuk development, tidak aktif di production (atau di-filter)
- `info` — event normal yang berguna untuk trace alur (request masuk, job selesai)
- `warn` — sesuatu yang tidak ideal tapi sistem masih jalan (retry, fallback ke default)
- `error` — operasi gagal, butuh perhatian tapi sistem masih hidup
- `fatal`/`panic` — sistem tidak bisa lanjut, biasanya diikuti crash/restart

**Wajib disertakan di tiap log error:** context yang cukup untuk reproduce tanpa harus tanya balik ke user — `request_id`/`trace_id` (untuk korelasi antar log di request yang sama), `user_id` kalau relevan, endpoint/operasi yang gagal, pesan error asli.

**Jangan pernah log data sensitif:** password (meski hashed), token/API key, nomor kartu kredit lengkap, data pribadi yang tidak perlu (NIK lengkap, dll) — masking/redact kalau field itu perlu muncul di log untuk konteks (`user_id` boleh, `user.password_hash` tidak boleh).

#### Audit Log

Dibutuhkan untuk aksi yang **mengubah data penting** dan perlu bisa ditelusuri siapa yang bertanggung jawab — terutama untuk aksi admin/privileged yang mengubah data milik orang lain (contoh: admin mengubah `subsidy_amount` karyawan, Super Admin menyalakan/mematikan fitur).

**Kapan wajib ada audit log** (bukan semua aksi butuh, jangan berlebihan):
- Perubahan data finansial/subsidi/pricing oleh admin
- Perubahan konfigurasi sistem yang berdampak luas (toggle fitur, ubah aturan bisnis global)
- Aksi privileged yang mengubah data milik user lain (admin edit/hapus data user)
- Login/akses ke data sensitif (kalau relevan untuk compliance)

**Tabel audit log — mengikuti konvensi database di bagian 2.5:**
```
audit_logs
├── id (PK)
├── actor_id        (FK ke users — siapa yang melakukan aksi)
├── action           (string — "update_subsidy", "toggle_rfid", "delete_user", dst — konsisten snake_case)
├── entity_type       (string — "user", "catering_settings", dst — nama tabel yang terdampak)
├── entity_id          (uuid — id row yang terdampak)
├── before_value        (jsonb, nullable — state sebelum perubahan)
├── after_value          (jsonb, nullable — state sesudah perubahan)
├── ip_address            (nullable)
├── created_at
```
- `before_value`/`after_value` cukup simpan field yang berubah, tidak perlu seluruh row kalau row-nya besar
- Audit log **tidak pernah di-update atau di-delete** setelah dibuat (append-only) — kalau perlu koreksi, buat entry baru, jangan edit entry lama (integritas audit trail rusak kalau bisa diubah)
- Penulisan audit log dilakukan di layer service (setelah aksi berhasil), bukan di controller/handler — supaya konsisten meskipun ada banyak entry point yang memicu aksi yang sama
