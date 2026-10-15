---
name: lazy
description: Shortcut — lazy senior dev mode. Kerjakan langsung dengan solusi paling sederhana dan terpendek yang benar-benar jalan (YAGNI, stdlib dulu, tanpa abstraksi yang tidak diminta), tanpa tiket, review, atau QA. Pakai sebagai /noskill:lazy <permintaan>.
disable-model-invocation: true
---

Kerjakan permintaan berikut langsung di sesi ini — tanpa tiket, agent, review, atau QA:

$ARGUMENTS

## Cara berpikir

Berhenti di langkah pertama yang menyelesaikan masalah. **Langkah 2 tidak boleh dilewati**, meskipun solusinya cuma satu baris stdlib:
1. **Perlu dibuat?** Kalau permintaan bisa dipenuhi tanpa kode baru (config yang sudah ada, perilaku yang sudah ada), lakukan itu.
2. **Sudah ada di codebase?** Sebelum menulis apa pun, grep konsepnya (misal `clamp|limit|min|max` untuk pembatasan nilai, `format|currency` untuk format uang) di folder helper/lib/utils. Kalau ada helper yang melakukan hal yang sama, pakai itu — helper yang sudah ada selalu menang atas versi inline, karena satu sumber kebenaran lebih penting daripada menghemat satu import.
3. **Standard library atau fitur framework?** Pakai.
4. **Dependency yang sudah terpasang?** Pakai. Jangan tambah dependency baru.
5. **Tulis kode minimal** yang benar.

## Aturan

- Diff sekecil mungkin: sentuh hanya file yang perlu. Tidak ada refactor, rename, reformat, atau "sekalian membenahi".
- Tidak ada abstraksi, interface, factory, wrapper, config, opsi, parameter, atau kode "buat nanti" yang tidak diminta. Dua-tiga baris yang mirip lebih baik daripada helper baru yang dipakai sekali.
- Yang **tidak** dipangkas: validasi input yang mencegah data rusak, error handling yang memang perlu, dan keamanan.
- Bukti tetap wajib: jalankan test atau command yang relevan. Kalau ada logic bisnis yang belum punya test, tambahkan satu test kecil (positif dan negatif dalam satu file). Tanpa bukti, jangan klaim selesai.

## Kapan berhenti

Kalau ternyata permintaan menyentuh aturan bisnis baru, skema database, lebih dari ±5 file, atau beberapa repo, jangan diteruskan diam-diam. Hentikan dan sarankan `/noskill:fix` (mode cepat dengan review dan QA) atau `/noskill:feature-flow`.

## Laporan (maksimal ±8 baris)

- File yang diubah
- Kata kunci yang di-grep dan helper yang dipakai ulang (atau "tidak ada")
- Kenapa ini cara paling sederhana (satu kalimat)
- Hasil test/command
- Yang tidak dicek, kalau ada
