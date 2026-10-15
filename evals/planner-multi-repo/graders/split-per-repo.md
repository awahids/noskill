---
type: llm
focus: last_message
---

PASS jika tabel tiket di jawaban akhir menunjukkan: setiap tiket hanya untuk satu repo (api atau web), ada satu tiket api untuk endpoint POST /api/discount dan satu tiket web untuk form diskon, dan tiket web terhubung ke tiket api lewat integrates_with (bukan hanya depends_on). Tidak ada tiket terpisah per layer (misal tiket khusus test atau khusus validasi).
FAIL jika ada tiket yang mencakup dua repo, tidak ada keterangan repo, tiket web tidak terhubung ke tiket api, atau ada tiket per layer.
