---
name: debug-assistant
description: >-
  Alur debugging terstruktur: reproduce → isolasi → diagnosa root cause → fix → verifikasi dengan bukti, termasuk integrasi eksternal (WMS API, n8n, Power Automate, Microsoft Graph). Gunakan saat user melaporkan error, stack trace, bug, "kok error", "gak jalan", atau API call gagal.
---

# Debug Assistant

Gunakan alur terstruktur ini setiap kali membantu debugging, alih-alih langsung menebak solusi. Tujuannya: temukan akar masalah (root cause), bukan cuma menghilangkan gejala.

## Alur Debugging

### 1. Reproduce
Sebelum menyimpulkan apa pun, pastikan masalahnya bisa direproduksi:
- Minta langkah persis yang dilakukan user (request, input, environment)
- Kalau ada error message/stack trace, minta full text-nya, jangan potong
- Tanyakan: apakah konsisten terjadi, atau kadang jalan kadang tidak? (indikasi race condition/timing issue)
- Untuk API: minta contoh request lengkap (method, headers, body) dan response yang diterima

### 2. Isolasi
Persempit area masalah sebelum menebak penyebab:
- Kapan terakhir kali ini berfungsi normal? Apa yang berubah sejak itu? (deploy baru, dependency update, config change)
- Apakah terjadi di semua environment atau spesifik satu (staging vs production, local vs server)?
- Kalau melibatkan integrasi eksternal (WMS API, Microsoft Graph, n8n, Power Automate) — isolasi apakah masalah di request kita, response mereka, atau di tengah (network/timeout/auth)

### 3. Diagnosa
Cek dari yang paling mungkin dulu, urutan prioritas:
1. **Input/validasi** — data yang masuk memang salah/tidak sesuai ekspektasi?
2. **Logic/business rule** — kondisi yang salah, off-by-one, null/undefined handling
3. **State/data** — data di database sudah dalam kondisi tidak konsisten sebelum request ini
4. **Konfigurasi/environment** — env var beda, secret salah, endpoint URL beda
5. **Eksternal/integrasi** — service lain down, rate limit, auth token expired
6. **Infra** — memory, timeout, concurrency

Untuk tiap hipotesis, sebutkan **cara verifikasi cepat** (log tambahan, query DB, curl manual) sebelum langsung ubah kode.

**Teknik diagnosa spesifik (pakai sesuai jenis bug):**

- **Root-cause tracing** — kalau bug muncul di titik A, jangan langsung asumsikan A tempatnya. Telusuri balik: dari mana data/state yang salah ini berasal? Ikuti call stack atau alur data mundur sampai ketemu titik **pertama kali** nilai itu jadi salah — bukan titik pertama kali *terlihat* salah. Contoh: error null di `order.total_amount` saat render — jangan langsung tambah null-check di situ, telusuri kenapa `total_amount` bisa null (kalkulasi di service? default value hilang di migration? race condition saat insert?).
- **Defense-in-depth** — setelah root cause ketemu dan fix di titik asal, pertimbangkan apakah perlu **lapisan validasi tambahan** di titik-titik lain yang rentan (bukan pengganti fix akar masalah, tapi pengaman kalau ada jalur lain yang belum ketahuan menghasilkan kondisi serupa). Jangan berhenti di satu titik fix kalau bug ini tipe yang bisa muncul dari banyak jalur.
- **Condition-based waiting** (untuk race condition/timing issue) — kalau gejalanya "kadang gagal, kadang berhasil" terkait timing (async, job queue, event), **jangan** fix dengan `setTimeout`/`sleep` tetap. Ganti dengan menunggu **kondisi aktual** yang harus terpenuhi (polling status, event listener, promise yang resolve saat kerjaan selesai) — delay tetap cuma menyembunyikan race condition, bukan menghilangkan.

### 4. Fix & Verifikasi
- Fix root cause, bukan gejala (contoh: kalau race condition, jangan cuma tambah `setTimeout` — lihat *condition-based waiting* di atas)
- Setelah fix, verifikasi ulang skenario reproduce dari langkah 1
- Cek apakah fix ini berpotensi memengaruhi bagian lain (side effect)

> **Evidence over claims — jangan klaim "sudah fix" tanpa bukti.** Sebelum bilang ke user bahwa bug sudah selesai:
> - Jalankan ulang skenario reproduce yang sama persis dari langkah 1, tunjukkan hasilnya (bukan cuma "seharusnya sudah benar berdasarkan perubahan kode ini")
> - Kalau ada test, jalankan test-nya dan tunjukkan hasilnya lolos — bukan asumsi "test pasti lolos karena logic-nya benar"
> - Kalau tidak bisa menjalankan/reproduce langsung (misal butuh environment yang tidak tersedia saat ini), katakan itu eksplisit ke user — jangan menyamarkan ketidakpastian sebagai kepastian
> - "Kemungkinan sudah fix" dan "sudah terverifikasi fix" adalah dua klaim berbeda — jangan pakai bahasa yang menyamarkan salah satu jadi terdengar seperti yang lain

### 5. Cegah Berulang (opsional tapi direkomendasikan)
- Perlu logging tambahan di titik ini untuk next time?
- Perlu test case baru supaya regresi ini ketahuan otomatis?
- Kalau ini kesalahan konfigurasi/proses, perlu update dokumentasi/checklist deploy?

## Format Output Saat Membantu Debug

Saat membantu user, susun jawaban dengan bagian:
1. **Kemungkinan penyebab** (urutkan dari paling mungkin)
2. **Cara verifikasi** tiap kemungkinan (spesifik: command, query, log yang perlu dicek)
3. **Rekomendasi fix** setelah penyebab dikonfirmasi — jangan kasih fix sebelum penyebab jelas, kecuali user cuma butuh quick patch sementara (sebutkan eksplisit kalau ini tambal sulam, bukan solusi permanen)

## Kasus Khusus: Integrasi API Eksternal
Karena sering kerja dengan WMS API, n8n, Power Automate, Microsoft Graph — untuk kasus ini selalu cek dulu:
- Apakah request curl/HTTP-nya sudah benar (headers, auth, body format)?
- Apakah response error dari pihak eksternal punya kode/pesan yang bisa langsung menunjukkan masalahnya (jangan asumsi sebelum baca response body lengkap)?
- Apakah ini masalah baru atau eksternal service memang sedang ada isu (cek status page kalau ada)?

## Prinsip Inti

**Evidence over claims.** Ini prinsip yang berlaku di semua tahap alur debugging, bukan cuma di langkah Fix & Verifikasi: jangan menyimpulkan penyebab tanpa bukti (log, query result, output command), dan jangan mengklaim masalah selesai tanpa menjalankan ulang skenario yang gagal. "Sepertinya ini penyebabnya" dan "sudah dikonfirmasi ini penyebabnya lewat [bukti X]" adalah dua level keyakinan berbeda — selalu jelas yang mana yang sedang disampaikan.
