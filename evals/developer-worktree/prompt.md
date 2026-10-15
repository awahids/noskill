---
description: Mode paralel — developer mengerjakan tiket di worktree yang diberikan, bukan di checkout utama, dan tetap memakai helper yang ada.
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Mode paralel. Kerjakan tiket docs/noskill/tickets/SHOP-002.md dengan agent developer dari plugin noskill (kalau tersedia). Direktori kerja tiket ini: .worktrees/SHOP-002 (git worktree di branch ticket/SHOP-002). Checkout utama sedang dipakai tiket lain, jadi jangan diubah.
