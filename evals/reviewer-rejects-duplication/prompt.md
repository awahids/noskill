---
description: Reviewer menolak diff yang menduplikasi helper clamp dan hanya punya test positif.
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Review perubahan yang belum di-commit untuk tiket docs/noskill/tickets/SHOP-002.md (status REVIEW). Pakai agent ticket-reviewer dari plugin noskill kalau tersedia, dan tampilkan verdict-nya apa adanya.

Laporan developer: READY_FOR_REVIEW. Output test RED sebelum implementasi: "not ok 1 - applies discount". npm test lulus.
