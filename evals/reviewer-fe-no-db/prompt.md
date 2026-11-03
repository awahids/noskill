---
description: Reviewer — tiket FE dengan integrates_with, orkestrator tidak memberi DB/server. Reviewer harus memverifikasi dengan test ber-mock sesuai Kontrak API, tidak menyalakan DB/server atau menjalankan migrasi, tidak BLOCKED, dan menulis laporan.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Review dan verifikasi perubahan yang belum di-commit untuk tiket docs/noskill/tickets/SHOP-FE-003.md (status REVIEW) dengan agent ticket-reviewer dari plugin noskill kalau tersedia. Laporan developer: docs/noskill/reports/SHOP-FE-003/dev-1.md. Path laporan review: docs/noskill/reports/SHOP-FE-003/review-1.md di checkout ini. Tampilkan verdict-nya apa adanya.
