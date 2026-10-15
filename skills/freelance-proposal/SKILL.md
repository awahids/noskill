---
name: freelance-proposal
description: >-
  Template proposal dan scoping project freelance: fase dengan deliverable yang bisa didemokan, timeline, harga dalam Rupiah per fase, dan syarat pembayaran. Gunakan saat user minta proposal, quotation, penawaran harga, atau estimasi project untuk client.
---

# Freelance Proposal & Scoping

Gunakan struktur ini setiap kali membantu menyusun proposal atau scoping untuk client freelance, supaya formatnya konsisten dan profesional dari satu client ke client lain.

## Struktur Proposal Standar

### 1. Ringkasan Kebutuhan
Parafrase kebutuhan client dalam 2-3 kalimat untuk konfirmasi pemahaman sebelum masuk ke detail teknis.

### 2. Lingkup Pekerjaan (Scope)
Pecah jadi **fase-fase** yang jelas, jangan satu blok besar. Pola yang sudah terbukti dipakai (contoh: web donasi dengan payment gateway + panel admin + notifikasi WhatsApp):

```
Fase 1: [Nama fase — misal "Core Platform & Donation Flow"]
- Deliverable 1
- Deliverable 2
- Estimasi waktu: X minggu

Fase 2: [Nama fase — misal "Admin Panel & Automation"]
- Deliverable 1
- Deliverable 2
- Estimasi waktu: X minggu
```

Setiap fase harus punya deliverable yang **bisa didemokan**, bukan cuma "development backend" yang abstrak.

### 3. Stack Teknologi
Sebutkan stack yang dipakai dan alasan singkat kalau relevan (misal: "Next.js untuk SEO donasi publik", "Filament untuk admin panel cepat tanpa build custom dashboard").

### 4. Timeline
Total durasi + breakdown per fase. Beri buffer realistis (jangan janji waktu terlalu mepet).

### 5. Harga (format IDR)
- Gunakan format Rupiah standar: `Rp 15.000.000` (titik sebagai pemisah ribuan, bukan koma)
- Pecah harga per fase kalau project multi-fase, supaya client bisa mulai dari fase 1 dulu
- Sebutkan dengan jelas apa yang **termasuk** (misal: revisi minor 2x, deployment awal) dan apa yang **tidak termasuk** (misal: biaya hosting/domain, maintenance setelah go-live)

```
| Fase | Deliverable | Estimasi Waktu | Harga |
|---|---|---|---|
| Fase 1 | Core platform + donation flow | 3 minggu | Rp 8.000.000 |
| Fase 2 | Admin panel + WA automation | 2 minggu | Rp 5.000.000 |
| **Total** | | **5 minggu** | **Rp 13.000.000** |
```

### 6. Syarat & Ketentuan Singkat
- Skema pembayaran (misal: DP 50% di awal, 50% sebelum go-live — atau per fase)
- Ketentuan revisi (berapa kali termasuk, revisi di luar itu dihitung terpisah)
- Apa yang jadi tanggung jawab client (konten, gambar, akun pihak ketiga seperti Midtrans)

## Panduan Estimasi Harga (acuan internal, sesuaikan dengan kompleksitas)

Pertimbangkan faktor berikut saat estimasi:
- Kompleksitas integrasi pihak ketiga (payment gateway, WhatsApp API, dll) menambah waktu signifikan
- Client tier (personal/UMKM vs korporat) memengaruhi budget range yang realistis ditawarkan
- Landing page/frontend showcase vs full-stack dengan admin panel — beda kompleksitas jauh
- Selalu diskusikan angka pasti dengan user sebelum finalisasi proposal — skill ini bantu strukturkan, bukan menentukan harga akhir secara otomatis

## Nada Penulisan
- Bahasa profesional tapi tidak kaku, sesuai gaya komunikasi Bahasa Indonesia yang natural
- Hindari jargon teknis berlebihan kalau client non-teknis — jelaskan istilah penting secukupnya
