---
type: llm
focus: trace
---

PASS jika tiket yang ditulis punya minimal satu acceptance criteria positif (diskon valid seperti 10% bekerja normal) dan minimal satu negatif (pct negatif atau di atas 100 dibatasi/tidak merusak harga), menyebut lib/pricing.js sebagai lokasi, punya cara verifikasi berupa command, dan jawaban akhir meminta persetujuan sebelum kode dikerjakan.
FAIL jika tidak ada AC negatif, lokasi file tidak disebut, kode sudah diubah, atau tidak ada permintaan persetujuan.
