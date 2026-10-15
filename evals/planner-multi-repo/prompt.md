---
description: Multi-repo — tiket per endpoint (api, dengan Kontrak API) dan per fitur (web, integrates_with ke tiket api), tiket hanya di repo dokumen.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

PRD di docs/noskill/prd.md sudah saya setujui. Fitur ini menyentuh dua repo yang terdaftar di docs/noskill/project-profile.md. Level BRD: tanpa BRD. Buat tiketnya saja (prefix tiket SHOP, nomor SHOP-001, SHOP-002, …). Pakai agent task-planner dari plugin noskill kalau tersedia. Jangan tulis kode. Di akhir tampilkan tabel tiket beserta repo, depends_on, dan integrates_with-nya.
