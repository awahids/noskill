---
description: cto mode SIGN_OFF memeriksa seluruh branch kerja dan menemukan masalah lintas tiket (logika clamp diduplikasi di voucher.js, padahal clamp/applyDiscount sudah ada), lalu memberi verdict CONCERNS tanpa mengubah kode.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Write, Bash, Glob, Grep, Skill, Agent]
---

Semua tiket di docs/noskill/tickets sudah DONE di branch feat/diskon (base: master atau main). Jalankan feature-flow Stage 6 bagian final review saja: panggil agent cto mode SIGN_OFF dengan branch feat/diskon, folder tiket docs/noskill/tickets, dan path laporan docs/noskill/reports/_cto/signoff-1.md. Jangan ubah kode dan jangan buat tiket baru; cukup tampilkan verdict dan temuannya.
