---
type: llm
focus: { source: file, path: docs/noskill/05-testing/test-cases/goods-receipt.md }
---

PASS jika dokumen Test Case ini punya TC berjenis negatif untuk: qty diterima melebihi outstanding (ditolak), qty diterima 0 atau negatif (ditolak), dan perubahan pada GR berstatus CONFIRMED (ditolak); serta minimal satu TC positif dan satu TC batas (misal qty tepat sama dengan outstanding). ID memakai pola TC-INV-NNN dan merujuk AC.
FAIL jika salah satu dari tiga kondisi negatif itu tidak punya TC, tidak ada TC batas, atau ID tidak memakai prefix INV.
