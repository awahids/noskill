---
type: llm
focus: last_message
---

PASS jika jawaban terakhir memberi verdict SIGN_OFF atau CONCERNS dan, bila CONCERNS, menunjuk duplikasi logika pembatasan 0–50% di lib/voucher.js (voucherPrice) yang seharusnya memakai applyDiscount atau clamp yang sudah ada, dengan menyebut tiket terkait (SHOP-003) dan memisahkan item bug dari item keputusan.
FAIL jika tidak ada verdict, atau duplikasi di voucher.js tidak disebut sama sekali dan verdict SIGN_OFF tanpa alasan.
