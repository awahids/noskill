# Parallel Mode (pipeline)

Baca file ini hanya saat user memilih mode paralel.

Like a real team: while ticket A is in review, the developer is already working on ticket B. Git repos only.

1. **Tickets that may run concurrently:** all their `depends_on` are DONE (`integrates_with` doesn't block — an FE ticket may be worked alongside its BE ticket based on the Kontrak API), their `File/Lokasi` doesn't overlap with another active ticket, and the ticket doesn't change dependencies/lockfile. Otherwise the ticket waits. Max 2 active tickets at once; **3 if the active tickets are in different repos** (e.g. a BE–FE pair in `api` and `web`, which can't conflict on files). The user may ask for more (max 4).
2. **Worktree per ticket:** before the developer starts, run `git worktree add .worktrees/<ID> -b ticket/<ID> <branch kerja>` and add `.worktrees/` to `.git/info/exclude`. If the project has uncommitted dependency folders (`node_modules`, `vendor`), symlink them inside the worktree so tests run without reinstalling.
3. **Send the working directory to agents:** every developer and reviewer call includes that ticket's worktree path. Ticket files stay in `<docs>/tickets/` in the main checkout, and only you write them.
4. **Run agents in the background** and process verdicts in the order they finish. As soon as the developer reports `READY_FOR_REVIEW` for ticket A, call the reviewer for A and at the same time the developer for the next eligible ticket.
5. **On DONE (APPROVED):** commit in the worktree (`<ID>: <title>`), then in the main checkout `git merge --no-ff ticket/<ID>` into the working branch. Then remove the ticket's worktree and branch, and commit the ticket file update.
   - **If the merge conflicts:** `git merge --abort`, set the ticket to `IN_PROGRESS` with the note "gabungkan branch kerja terbaru ke ticket/<ID> dan selesaikan konflik", and the ticket goes through review again.
6. Total tokens are about the same as sequential mode since the work is the same; what shrinks is waiting time.
