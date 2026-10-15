---
type: llm
focus: { source: file, path: docs/noskill/tickets/SHOP-001.md }
---

PASS jika tiket ini berstatus TODO, punya minimal satu acceptance criteria positif dan minimal satu negatif atau batas yang diambil dari aturan di PRD (bukan dikarang), `File/Lokasi` menyebut path nyata seperti lib/pricing.js, dan punya Cara Verifikasi berupa command.
FAIL jika tidak ada AC negatif/batas, lokasi file generik atau tidak ada, atau AC tidak sesuai PRD.
