---
name: freelance-proposal
description: >-
  Freelance proposal and scoping template: phases with demoable deliverables, timeline, per-phase pricing in Rupiah, and payment terms. Use for "buatkan proposal", "quotation", "penawaran harga", or a client project estimate.
---

# Freelance Proposal & Scoping

Write the output in Bahasa Indonesia unless the user asks otherwise.

Use this structure every time you help draft a proposal or scoping for a freelance client, so the format stays consistent and professional across clients.

## Struktur Proposal Standar

### 1. Ringkasan Kebutuhan
Paraphrase the client's needs in 2-3 sentences to confirm understanding before getting into technical details.

### 2. Lingkup Pekerjaan (Scope)
Split into clear **phases**, not one big block. Proven pattern (example: donation website with payment gateway + admin panel + WhatsApp notifications):

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

Every phase must have **demoable** deliverables, not just an abstract "backend development".

### 3. Stack Teknologi
Name the stack and a short reason where relevant (e.g. "Next.js untuk SEO donasi publik", "Filament untuk admin panel cepat tanpa build custom dashboard").

### 4. Timeline
Total duration + breakdown per phase. Add a realistic buffer (don't promise overly tight timelines).

### 5. Harga (format IDR)
- Use standard Rupiah format: `Rp 15.000.000` (dot as thousands separator, not comma)
- Split pricing per phase for multi-phase projects, so the client can start with phase 1 first
- State clearly what is **included** (misal: revisi minor 2x, deployment awal) and what is **not included** (misal: biaya hosting/domain, maintenance setelah go-live)

```
| Fase | Deliverable | Estimasi Waktu | Harga |
|---|---|---|---|
| Fase 1 | Core platform + donation flow | 3 minggu | Rp 8.000.000 |
| Fase 2 | Admin panel + WA automation | 2 minggu | Rp 5.000.000 |
| **Total** | | **5 minggu** | **Rp 13.000.000** |
```

### 6. Syarat & Ketentuan Singkat
- Payment scheme (misal: DP 50% di awal, 50% sebelum go-live — atau per fase)
- Revision terms (how many are included; revisions beyond that are billed separately)
- Client responsibilities (konten, gambar, akun pihak ketiga seperti Midtrans)

## Pricing Estimation Guide (internal reference, adjust to complexity)

Consider these factors when estimating:
- Third-party integration complexity (payment gateway, WhatsApp API, etc.) adds significant time
- Client tier (personal/UMKM vs corporate) affects the realistic budget range to offer
- Landing page/frontend showcase vs full-stack with admin panel — very different complexity
- Always discuss exact figures with the user before finalizing the proposal — this skill helps structure, it doesn't set the final price automatically

## Writing Tone
- Professional but not stiff, in natural Bahasa Indonesia communication style
- Avoid excessive technical jargon for non-technical clients — explain key terms just enough
