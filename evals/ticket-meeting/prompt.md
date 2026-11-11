---
description: feature-flow mode default (dua tiket, salah satunya kompleks, jadi aturan lewati rapat tidak berlaku) menggelar rapat tiket sebelum menulis tiket: planner, reviewer, dan developer dipanggil dengan Mode RAPAT dalam satu putaran, notulen ditulis, tiket dibuat, kode tidak diubah, berhenti di gate.
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep, Skill, Agent]
---

Jalankan feature-flow mode default untuk permintaan ini: "(1) applyDiscount di lib/pricing.js harus membatasi pct ke 0–50 dan hasilnya dibulatkan ke rupiah terdekat; (2) fungsi baru applyVoucher(price, code) di lib/voucher.js dengan kuota 100 pemakaian per kode yang aman untuk checkout bersamaan". Buat rencana tiketnya saja, lengkap dengan rapat tiket sesuai aturan feature-flow, lalu berhenti di gate persetujuan. Jangan tulis kode dan jangan jalankan Stage 5.
