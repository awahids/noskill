---
name: standup-update
description: >-
  Summarizes commits, tasks, or work notes into a standup update (Yesterday/Today/Blockers) or a weekly status report. Use for "standup", "update harian", "status report", or "progress report".
---

# Standup & Status Update Generator

Write the output in Bahasa Indonesia unless the user asks otherwise.

noskill docs folder — written as `<docs>` below: `docs/noskill` by default. If that folder doesn't exist, find the folder holding `tickets/*.md` with a `status:` line (Glob, excluding `node_modules`).

Use this skill to turn raw work notes (commit messages, task lists, progress notes) into a tidy update the team can read easily, without the user rewriting it from scratch.

## Standard Format: Daily Standup

```
**Yesterday**
- [Task/fitur yang diselesaikan, dalam bahasa hasil bukan proses — "Selesai integrasi payment gateway" bukan "Ngerjain payment gateway"]

**Today**
- [Rencana kerja hari ini, spesifik bukan generik — "Lanjut testing webhook Midtrans" bukan "Lanjut kerja"]

**Blockers**
- [Kalau ada, sebutkan spesifik apa yang menghambat dan siapa/apa yang dibutuhkan untuk resolve. Kalau tidak ada, tulis "Tidak ada" — jangan dikosongkan]
```

## Alternative Format: Weekly/Project Status (Notion-friendly)

For weekly updates or project reports (this format also pastes cleanly into Notion):

```
## [Nama Project] — Update Minggu [tanggal]

**Progress**
- [Poin-poin yang sudah selesai, dikelompokkan per area kalau perlu — Backend, Frontend, Integrasi]

**In Progress**
- [Yang sedang dikerjakan + estimasi selesai kalau ada]

**Next**
- [Rencana minggu depan]

**Risks/Blockers**
- [Kalau ada risiko timeline atau dependency yang belum jelas]
```

## How It Works

0. **If the project uses the noskill ticket flow** (`<docs>/tickets/` exists), make it the primary source, without asking the user to rewrite anything:
   - Tickets moved to DONE since the last update (`## Riwayat` lines dated yesterday/today) → **Yesterday**
   - Tickets with status IN_PROGRESS, REVIEW, QA, or BUG → **Today**
   - HOLD tickets with their questions → **Blockers**
   - Supplement with `git log --since=<tanggal> --oneline` if needed, but write in outcome language, not a commit list.

1. If the user gives raw input (commit log, task list, or a free-form account of what they did), extract it into outcome points — don't just copy-paste raw commit messages
2. Turn process language into outcome language: a technical commit message like `fix: null pointer in order service` → in the update becomes "Perbaiki bug null pointer di order service yang menyebabkan [dampak, kalau diketahui]"
3. Group by project/area if the user works on several things at once (e.g. an office project and a freelance project on the same day) — keep them separate for clarity
4. If a blocker is mentioned implicitly (user says "masih nunggu API key dari client"), lift it explicitly into the Blockers section; don't bury it in the Today narrative

## Tone
Concise, outcome-oriented, no long rambling sentences. Standups are read quickly by the team, not narrative reports.
