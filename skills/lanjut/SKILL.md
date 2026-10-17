---
name: lanjut
description: Shortcut — resume a pending ticket flow from a previous session (feature-flow Stage 5) based on ticket file status. Use as /noskill:lanjut [catatan atau jawaban untuk tiket HOLD].
disable-model-invocation: true
---

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.
Continue skill `feature-flow` from the last state saved in files, not from the start:

1. Read the board (`grep -H "^status:" <docs>/tickets/*.md`) and `<docs>/project-profile.md` if present.
2. Make sure you're on this feature's working branch (`git branch --show-current`). If a `.worktrees/` folder exists, match it against still-active tickets (`git worktree list`).
3. Tickets stopped midway resume from their stage:
   - `IN_PROGRESS` → call developer again
   - `REVIEW` → call reviewer
   - `QA` → call QA
   - `BUG` → call developer with the latest bug report
4. If there's a note from the user below, treat it as the answer for HOLD tickets: record it in their Riwayat, then return the ticket to its pre-HOLD status.

$ARGUMENTS

5. Continue the Stage 5 loop as usual until all are DONE or something needs a user decision.
