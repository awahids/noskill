---
type: llm
focus: last_message
---

PASS jika ringkasan akhir menyebut jumlah US, AC, TECH, dan TC dengan ID berprefix INV (misal US-INV-001, TC-INV-001), dan hal yang tidak tertulis di PRD dijadikan pertanyaan terbuka. Asumsi sementara boleh, asalkan ditandai jelas sebagai asumsi/usulan dan tetap ditanyakan.
FAIL jika tidak ada ID berprefix INV, atau ada aturan bisnis baru yang disajikan sebagai fakta (bukan asumsi/pertanyaan).
