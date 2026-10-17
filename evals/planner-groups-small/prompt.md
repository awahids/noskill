---
description: Tanpa BRD — task-planner menggabungkan endpoint kecil di resource yang sama jadi satu tiket, memisahkan endpoint dengan aturan bisnis, dan menulis AC batas dari checklist (batas kolom int4, kode case-insensitive).
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

PRD di docs/noskill/prd.md sudah saya setujui. Level BRD: tanpa BRD. Buat tiketnya saja (prefix tiket SHOP, nomor SHOP-001, SHOP-002, …; codebase di folder ini). Pakai agent task-planner dari plugin noskill kalau tersedia. Jangan tulis kode. Di jawaban akhir tampilkan daftar tiket beserta endpoint dan AC masing-masing.
