---
type: llm
focus: last_message
---

PASS jika jawaban akhir reviewer menyebut `clamp` (di lib/math.js) sebagai helper yang sudah ada dan harus dipakai, bukan logika batas yang ditulis ulang di lib/pricing.js.
FAIL jika duplikasi logika pembatasan nilai tidak disebut, atau reviewer menyatakan tidak ada duplikasi.
