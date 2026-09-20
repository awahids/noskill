---
name: mockup-prototype
description: Membuat mockup/prototype UI (HTML atau React interaktif) berdasarkan PRD yang sudah ada — menerjemahkan Core Features, User Flow, dan Requirements/RBAC di PRD menjadi wireframe/mockup per layar dan per role. Gunakan skill ini setiap kali user minta "buatkan mockup", "buatkan prototype", "wireframe untuk PRD ini", "desain UI dari requirement ini", atau setelah PRD selesai dibuat dan user mau lanjut ke tahap visual. Bekerja sama dengan skill `frontend-design` untuk kualitas visual dan `prd-writer` sebagai sumber requirement.
---

# Mockup & Prototype Builder

Menerjemahkan PRD (dari skill `prd-writer` atau PRD yang sudah ada) menjadi mockup/prototype yang bisa langsung dilihat dan diklik-klik, sebelum masuk ke development sungguhan.

## Alur Kerja

### 1. Ekstrak Layar dari PRD

Sebelum mendesain, petakan dulu dari PRD:
- **Dari "Aksesibilitas Pengguna" & "Peran & Hak Akses"** → daftar platform (web/mobile/kiosk) dan role apa saja yang butuh tampilan berbeda
- **Dari "Core Features"** → tiap fitur biasanya = 1 layar atau 1 komponen signifikan
- **Dari "User Flow"** → urutan layar yang dilalui user, termasuk state kondisional (loading, error, empty, sukses)

Susun daftar layar terlebih dahulu sebagai checklist sebelum mulai membangun, kelompokkan per role/platform:
```
Role: [Nama Role] — Platform: [Web/Mobile]
- [ ] Layar A — [fitur terkait dari Core Features]
- [ ] Layar B — [fitur terkait]
```

Kalau jumlah layar banyak (>5-6), konfirmasi ke user mana yang diprioritaskan dulu — jangan langsung generate semua sekaligus tanpa arahan kalau scope-nya besar.

### 2. Tentukan Fidelity & Format

Tanyakan/tentukan sesuai konteks kalau belum jelas dari permintaan user:
- **Wireframe (low-fidelity)** — struktur & layout saja, greyscale, fokus ke informasi hierarchy dan flow. Cocok untuk validasi flow sebelum invest ke visual detail
- **Mockup (high-fidelity)** — sudah pakai warna, tipografi, komponen visual lengkap, tapi belum tentu interaktif penuh
- **Prototype (interaktif)** — high-fidelity + bisa diklik berpindah antar layar, mensimulasikan flow yang sebenarnya

Default ke **high-fidelity mockup** kalau user tidak spesifik, karena paling berguna untuk didiskusikan dengan stakeholder/client.

### 3. Cek Design System yang Sudah Ada

**Sebelum membuat palet/tipografi baru, cek dulu apakah project ini punya design system existing** (relevan karena beberapa project user sudah punya identitas visual):
- Kalau project ini kelanjutan dari sistem yang sudah ada (misal terintegrasi ke aplikasi existing seperti kasus SmartCatering ke Absensi) → **ikuti visual language aplikasi existing**, jangan bikin baru
- Kalau project baru berdiri sendiri tanpa arahan visual → baca skill `frontend-design` untuk prinsip desain, dan tanyakan preferensi arah visual ke user kalau belum ada petunjuk dari PRD (industri/audience biasanya memberi sinyal: sistem internal HR/GA cenderung clean & functional, produk konsumen bisa lebih ekspresif)

### 4. Build Mockup

**Selalu baca `frontend-design` sebelum membangun kalau skill itu tersedia di environment ini** (biasanya ada bawaan di `/mnt/skills/public/frontend-design/SKILL.md` pada Claude.ai/Claude Code) — ikuti prinsip desain di sana untuk tipografi, spacing, dan hierarki visual, jangan pakai default template generik. **Kalau skill itu tidak ada di environment yang sedang dipakai**, tetap terapkan prinsip dasarnya secara manual: hindari font/warna default yang terlalu umum (Inter polos, gradient ungu generik), pilih arah visual yang disengaja sesuai konteks project, dan perhatikan hierarki tipografi — jangan biarkan ketidaktersediaan skill itu jadi alasan menghasilkan mockup generik.

**Format output:**
- **Single screen / komponen** → React artifact (`.jsx`), pakai Tailwind + lucide-react sesuai batasan environment
- **Multi-screen prototype dengan navigasi antar layar** → satu file HTML dengan simple client-side routing (tampilkan/sembunyikan section berdasarkan state), atau beberapa React artifact terpisah kalau lebih mudah dikelola per layar
- **Flow dengan banyak role berbeda** → pisahkan file per role supaya tidak campur aduk (`mockup-employee.jsx`, `mockup-admin.jsx`, dst)

**Yang wajib direfleksikan dari PRD ke mockup:**
- Field yang ditampilkan di layar sesuai kolom database/DTO yang disebut di PRD (jangan mengarang field yang tidak ada di schema)
- State kosong/loading/error untuk data yang sifatnya async (sesuai catatan di PRD kalau ada)
- Pembatasan akses role tercermin di UI — kalau PRD bilang suatu role "read-only", mockup untuk role itu tidak boleh menampilkan tombol edit/hapus
- Alur kondisional dari User Flow (misal toggle RFID ON/OFF mengubah tampilan layar klaim) direpresentasikan sebagai state yang bisa di-switch di prototype, bukan cuma satu kondisi statis

### 5. Review Pass Akhir (sebelum dianggap selesai)

Setelah mockup/prototype selesai dibangun, **lakukan satu pass review terhadap hasilnya sendiri** sebelum dipresentasikan ke user sebagai final — bukan langsung disajikan ke user begitu kode selesai dibuat:

- **Konsistensi spacing & alignment** — elemen sejenis (card, list item, tombol) pakai spacing yang konsisten, tidak ada yang terlihat "hampir sejajar tapi tidak"
- **Hierarki visual** — informasi paling penting di layar itu (harga, status, CTA utama) memang paling menonjol, bukan tenggelam sama elemen dekoratif
- **Kontras & keterbacaan** — teks di atas background berwarna/gambar tetap kebaca jelas, ukuran font untuk teks penting tidak terlalu kecil
- **Konsistensi lintas layar** — kalau ada beberapa layar/state dalam satu prototype, komponen yang sama (tombol, card, navigasi) terlihat konsisten di semua layar, bukan berubah gaya tiap layar
- **Accessibility dasar** — target klik/tap cukup besar untuk elemen interaktif, tidak mengandalkan warna saja untuk menyampaikan informasi penting (misal status error cuma beda warna tanpa ikon/teks)

Kalau ketemu masalah dari review ini, perbaiki dulu sebelum present ke user — jangan serahkan hasil yang sudah diketahui ada masalah kecil dengan asumsi "nanti user yang bilang". Untuk masalah yang butuh keputusan desain (bukan sekadar bug visual jelas), boleh disebutkan ke user sebagai catatan alih-alih diam-diam diputuskan sendiri.

### 6. Anotasi Singkat

Setelah mockup jadi, kalau ada keputusan desain yang perlu penjelasan (kenapa layout tertentu dipilih, komponen mana yang representasi dari fitur PRD yang mana), sampaikan singkat di chat — tidak perlu bikin dokumen anotasi terpisah kecuali diminta.

## Prinsip

1. **Mockup mengikuti PRD, bukan sebaliknya.** Kalau ada kebutuhan visual yang tidak tercakup PRD (misal butuh state baru yang belum disebutkan), sebutkan itu ke user sebagai gap yang mungkin perlu ditambahkan ke PRD, jangan diam-diam mengarang requirement baru.
2. **Realistis terhadap data.** Pakai contoh data yang masuk akal sesuai domain PRD (nama menu katering, nominal rupiah, dll), bukan "Lorem ipsum" atau "Item 1, Item 2".
3. **Fidelity sesuai tujuan.** Prototype untuk internal review cukup functional; untuk dipresentasikan ke client/stakeholder eksternal, tingkatkan polish visualnya.
4. **Jangan over-build di awal.** Kalau PRD besar dengan banyak role dan layar, mulai dari 1-2 layar paling representatif dulu untuk divalidasi arahnya, baru lanjut ke sisanya — sesuai preferensi "lazy/minimal" yang efisien (selaras dengan skill `ponytail` kalau user memakainya untuk kode, prinsip serupa berlaku untuk scope mockup: jangan bangun semua layar sebelum arah desain dikonfirmasi).

## Referensi Skill Terkait
- `prd-writer` — sumber PRD yang jadi acuan
- `frontend-design` (built-in) — prinsip visual, tipografi, dan styling
- `coding-standards` — kalau mockup ini nantinya dilanjutkan jadi kode production, pastikan struktur komponen/naming yang dipakai di mockup sudah selaras supaya transisinya mulus
