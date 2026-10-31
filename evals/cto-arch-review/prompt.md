---
description: cto mode ARCH_REVIEW menulis laporan dengan verdict yang jelas, memakai helper yang ada, dan tidak mengubah kode atau membuat tiket.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

PRD di docs/noskill/prd.md sudah saya setujui. Jalankan feature-flow Stage 2b saja: panggil agent cto mode ARCH_REVIEW dengan folder ADR docs/noskill/adr/ dan path laporan docs/noskill/reports/_cto/arch-1.md. Jangan buat BRD atau tiket, dan jangan tulis kode.
