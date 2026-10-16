---
type: llm
focus: last_message
---

PASS jika ringkasan akhir menyebut jumlah US, AC, TECH, dan TC dengan ID berprefix INV (misal US-INV-001, TC-INV-001), ada AC/TC untuk sisi negatif (qty melebihi outstanding ditolak, qty 0 atau negatif ditolak, GR CONFIRMED tidak bisa diubah), dan tidak ada aturan bisnis yang dikarang di luar PRD (hal yang tidak jelas dijadikan pertanyaan terbuka).
FAIL jika tidak ada AC/TC negatif, ID tidak memakai prefix INV, atau ringkasan mengarang aturan yang tidak ada di PRD.
