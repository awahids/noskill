---
type: llm
focus: last_message
---

PASS jika profil yang ditulis memuat command test yang benar untuk repo ini (`npm test` / `node --test`), struktur folder lib/, dan helper yang sudah ada (clamp di lib/math.js, applyDiscount di lib/pricing.js) sehingga agent tidak perlu menjelajah ulang.
FAIL jika command test salah atau tidak ada, helper clamp tidak tercatat, atau profil berisi saran refactor.
