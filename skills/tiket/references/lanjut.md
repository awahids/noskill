# lanjut — resume the ticket flow

Continue skill `feature-flow` from the last state saved in files, not from the start:

1. Read the board (`grep -H "^status:" <docs>/tickets/*.md`) and `<docs>/project-profile.md` if present.
2. Make sure you're on this feature's working branch (`git branch --show-current`). If a `.worktrees/` folder exists, match it against still-active tickets (`git worktree list`).
3. Tickets stopped midway resume from their stage:
   - `IN_PROGRESS` → call the developer agent picked by the ticket's `layer` again
   - `REVIEW` → call reviewer
   - `QA` → call QA
   - `BUG` → call that developer agent with the latest bug report
4. If the user gave a note after `lanjut`, treat it as the answer for HOLD tickets: record it in their Riwayat, then return the ticket to its pre-HOLD status.

5. Continue the Stage 5 loop as usual until all are DONE or something needs a user decision.
