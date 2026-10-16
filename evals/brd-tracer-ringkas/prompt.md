---
description: brd-tracer dengan skill erp-requirements — PRD Goods Receipt jadi dokumen BRD level ringkas (US → AC → TECH + TC) dengan ID traceable dan TC positif/negatif.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

PRD di docs/noskill/prd.md sudah disetujui. Jalankan tahap BRD dengan agent brd-tracer dari plugin noskill: prefix domain INV, level ringkas (US → AC → TECH + TC). Tampilkan ringkasan jumlah US/AC/TECH/TC dan pertanyaan terbuka kalau ada.
