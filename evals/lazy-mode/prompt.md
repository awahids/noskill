---
description: /noskill:lazy — solusi terpendek yang jalan, memakai clamp yang sudah ada, tanpa helper/abstraksi baru, tanpa tiket atau agent, kode lama tidak disentuh.
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

/noskill:lazy applyDiscount di lib/pricing.js harus membatasi pct ke 0–50 (di atas 50 jadi 50, negatif jadi 0).
