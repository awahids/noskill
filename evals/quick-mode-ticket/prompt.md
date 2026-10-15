---
description: Bug kecil lewat mode cepat — satu tiket dengan AC positif & negatif, berhenti di gate sebelum kode ditulis.
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

Ada bug: applyDiscount di lib/pricing.js bisa menaikkan harga kalau pct negatif, dan diskon di atas 100% bikin harga minus. Diskon harus dibatasi 0–100%. Tolong kerjakan lewat alur tiket dengan review dan QA. Untuk sekarang cukup sampai tiketnya ditulis, lalu tunggu persetujuan saya sebelum menyentuh kode.
