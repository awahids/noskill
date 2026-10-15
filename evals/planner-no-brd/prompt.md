---
description: Tanpa BRD — task-planner membuat tiket langsung dari PRD dengan AC positif & negatif, trace "—", tanpa dokumen BRD.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

PRD di docs/noskill/prd.md sudah saya setujui. Level BRD: tanpa BRD. Buat tiketnya saja (prefix tiket SHOP, nomor SHOP-001, SHOP-002, …; codebase di folder ini). Pakai agent task-planner dari plugin noskill kalau tersedia. Jangan tulis kode.
