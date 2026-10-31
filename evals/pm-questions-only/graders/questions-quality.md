---
type: llm
focus: last_message
---

PASS jika jawaban terakhir berisi minimal 5 pertanyaan klarifikasi yang spesifik untuk fitur voucher diskon (misalnya jenis potongan persen atau nominal, batas pemakaian, masa berlaku, siapa yang boleh membuat voucher, apakah bisa digabung dengan diskon yang sudah ada di applyDiscount), dan menunggu jawaban user.
FAIL jika kurang dari 5 pertanyaan, pertanyaannya generik dan tidak menyinggung voucher sama sekali, atau jawaban sudah berisi draf PRD.
