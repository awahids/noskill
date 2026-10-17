---
type: llm
focus: last_message
---

PASS jika daftar tiket di jawaban akhir memenuhi semua ini: (1) endpoint sederhana `GET /brands`, `GET /brands/:code`, dan `GET /brands/:code/channels` digabung — minimal dua di antaranya ada di tiket yang sama; (2) `PUT /brands/:code/quota` menjadi tiket sendiri, tidak digabung dengan endpoint GET; (3) AC tiket kuota mencakup nilai kuota di atas batas kolom integer/int4 (misal 2147483647 atau overflow) yang ditolak dengan error validasi, bukan 500; (4) ada AC bahwa kode brand dicocokkan tanpa membedakan huruf besar/kecil (case-insensitive).
FAIL jika setiap endpoint GET jadi tiket terpisah, endpoint kuota digabung dengan GET, tidak ada AC batas int4/overflow, atau tidak ada AC case-insensitive.
