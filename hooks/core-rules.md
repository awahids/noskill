noskill — aturan kerja inti. Berlaku untuk setiap tugas coding di sesi ini, juga saat tidak ada skill yang dipanggil:

- Scope: perubahan kode hanya menyentuh yang diminta. Refactor, rename, reformat, dependency baru, atau "sekalian membenahi" kode lain tidak dilakukan tanpa diminta; temuan di luar scope cukup dilaporkan.
- Pikir dulu: sebelum mengedit, file yang akan diubah dan pendekatannya sudah ditentukan.
- Sederhana dulu: perlu dibuat atau tidak → sudah ada di codebase → standard library → dependency yang terpasang → kode minimal. Tidak ada abstraksi, config, atau opsi yang tidak diminta. Validasi input, error handling yang mencegah data rusak, dan keamanan tidak dipangkas.
- Reuse: helper/service yang sudah ada dicari (grep) dan dipakai, meskipun penggantinya cuma satu baris. Logic bisnis ada di service/lib, bukan di UI atau controller.
- Test: logic bisnis punya test positif, negatif, dan batas. Test dibuktikan gagal dulu (RED) sebelum implementasi.
- Kode efisien: tidak ada query di dalam loop (N+1), ambil hanya kolom/baris yang dibutuhkan, data besar dipaginasi, hindari loop bersarang di data besar. Optimasi mikro tanpa masalah nyata tidak dilakukan.
- Hemat token: cari dulu dengan grep/glob, lalu baca hanya bagian file yang relevan (pakai offset/limit untuk file besar); file yang baru diedit tidak dibaca ulang; output command dibatasi (`| tail -n 30`, mode quiet) dan yang dilaporkan hanya ringkasannya (jumlah pass/fail, nama test yang gagal); test yang relevan dijalankan dulu, suite penuh sekali di akhir; tool call yang tidak saling bergantung dijalankan paralel.
- Bukti: "selesai" atau "sudah fix" hanya diklaim setelah test/command dijalankan dan output-nya terlihat. Yang belum dicek disebut terus terang.
- Jawaban: ringkas dan langsung ke hasil; akhiri dengan apa yang dilewati atau belum dicek, dan risikonya kalau ada.
- Detail standar ada di skill `coding-standards`. Alur kerja dengan review dan QA ada di skill `feature-flow` (mode cepat untuk perubahan kecil, mode lengkap dari PRD).
