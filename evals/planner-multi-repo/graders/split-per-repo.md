---
type: llm
focus: last_message
---

PASS jika tabel tiket di jawaban akhir menunjukkan: setiap tiket hanya untuk satu repo (api atau web), ada minimal satu tiket api dan satu tiket web, tiket web punya depends_on ke tiket api yang membatasi diskon. Kalau path File/Lokasi ditampilkan, path tiket web relatif terhadap repo web (src/discount-form.js, bukan web/src/...).
FAIL jika ada tiket yang mencakup dua repo, tidak ada kolom/keterangan repo, atau tiket web tidak bergantung pada tiket api.
