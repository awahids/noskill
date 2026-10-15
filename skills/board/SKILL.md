---
name: board
description: Shortcut — tampilkan board tiket per status, plus pertanyaan yang menunggu jawaban di tiket HOLD. Pakai sebagai /noskill:board.
disable-model-invocation: true
---

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.
Tampilkan board dari `<docs>/tickets/` tanpa mengubah file apa pun:

1. Ambil status semua tiket sekaligus: `grep -H "^status:\|^title:\|^rounds:" <docs>/tickets/*.md`. Jangan membaca file tiket satu per satu kecuali untuk tiket HOLD.
2. Tampilkan satu tabel berurutan TODO · IN_PROGRESS · REVIEW · QA · BUG · HOLD · DONE, dengan kolom ID, judul, dan rounds.
3. Untuk tiket HOLD, baca baris terakhir `## Riwayat`-nya dan tampilkan pertanyaan yang menunggu jawaban user.
4. Tutup dengan satu baris: jumlah per status dan tiket berikutnya yang akan diambil sesuai urutan di skill `ticket-workflow`.

Kalau `<docs>/tickets/` tidak ada, katakan belum ada tiket dan sarankan `/noskill:fix` atau `/noskill:feature-flow`.
