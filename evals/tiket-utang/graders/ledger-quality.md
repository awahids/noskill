---
type: llm
focus: last_message
---

PASS jika jawaban terakhir berisi ledger dengan tepat dua penanda (lib/cache.js dan lib/retry.js), menandai lib/retry.js sebagai tanpa pemicu upgrade (`tanpa-pemicu`), TIDAK memasukkan lib/notes.js (itu "shortcut keyboard", bukan penanda), menutup dengan hitungan seperti "2 penanda, 1 tanpa pemicu", dan menawarkan (bukan melakukan) menulis file atau membuat tiket.
FAIL jika notes.js dimasukkan, retry.js tidak ditandai, atau file ledger ditulis tanpa diminta.
