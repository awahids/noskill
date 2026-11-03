---
description: Reviewer (review + QA) — implementasi benar, memakai helper clamp, dan test lengkap; reviewer harus APPROVED dengan bukti per AC (positif, negatif, batas), tidak mengubah kode, dan menulis laporan.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Review dan verifikasi perubahan yang belum di-commit untuk tiket docs/noskill/tickets/SHOP-002.md (status REVIEW) dengan agent ticket-reviewer dari plugin noskill kalau tersedia. Laporan developer: docs/noskill/reports/SHOP-002/dev-1.md. Path laporan review: docs/noskill/reports/SHOP-002/review-1.md di checkout ini. Tampilkan verdict-nya apa adanya.
