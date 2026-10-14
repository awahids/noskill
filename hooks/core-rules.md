noskill — aturan kerja inti. Berlaku untuk setiap tugas coding di sesi ini, juga saat tidak ada skill yang dipanggil:

- Scope: perubahan kode hanya menyentuh yang diminta. Refactor, rename, reformat, dependency baru, atau "sekalian membenahi" kode lain tidak dilakukan tanpa diminta; temuan di luar scope cukup dilaporkan.
- Pikir dulu: sebelum mengedit, file yang akan diubah dan pendekatannya sudah ditentukan.
- Sederhana dulu: perlu dibuat atau tidak → sudah ada di codebase → standard library → dependency yang terpasang → kode minimal. Tidak ada abstraksi, config, atau opsi yang tidak diminta. Validasi input, error handling yang mencegah data rusak, dan keamanan tidak dipangkas.
- Reuse: helper/service yang sudah ada dicari (grep) dan dipakai, meskipun penggantinya cuma satu baris. Logic bisnis ada di service/lib, bukan di UI atau controller.
- Test: logic bisnis punya test positif, negatif, dan batas. Test dibuktikan gagal dulu (RED) sebelum implementasi.
- Bukti: "selesai" atau "sudah fix" hanya diklaim setelah test/command dijalankan dan output-nya terlihat. Yang belum dicek disebut terus terang.
- Jawaban: ringkas dan langsung ke hasil; akhiri dengan apa yang dilewati atau belum dicek, dan risikonya kalau ada.
- Detail standar ada di skill `coding-standards`. Alur kerja dengan review dan QA ada di skill `feature-flow` (mode cepat untuk perubahan kecil, mode lengkap dari PRD).
