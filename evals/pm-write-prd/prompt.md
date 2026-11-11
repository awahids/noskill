---
description: product-manager mode WRITE menulis PRD ringkas (MVP) dari jawaban user, dengan diagram Mermaid, daftar [asumsi], dan tanpa kode atau tiket.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Write, Glob, Grep, Skill, Agent]
---

Fitur voucher diskon untuk toko ini. Jalankan feature-flow mode lengkap Stage 1–2 langkah kedua saja: panggil agent product-manager mode WRITE dengan PRD di docs/noskill/prd.md. Jawaban saya untuk pertanyaan klarifikasi: potongan persen saja (bukan nominal), kuota total 100 pemakaian per voucher, berlaku sampai tanggal kedaluwarsa, dibuat oleh admin, tidak bisa digabung dengan voucher lain, dan memakai applyDiscount yang sudah ada. Jangan buat BRD atau tiket, dan jangan tulis kode.
