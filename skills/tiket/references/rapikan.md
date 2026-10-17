# rapikan — tidy tickets or re-review a DONE ticket

Arguments are the words after `rapikan`:

- Empty or a ticket ID → **Tidy backlog** (all eligible tickets, or only that ID).
- Starts with `review` followed by a ticket ID → **Re-review DONE ticket**.

You act as the orchestrator (`feature-flow`), so you may change ticket files — but only after the user approves the proposal.

## Tidy backlog

Only tickets with status `TODO` and `HOLD` are processed. `IN_PROGRESS`, `REVIEW`, `QA`, `BUG`, and `DONE` tickets are not changed; if they have problems, just mention them in the report.

1. Get the board overview at once: `grep -H "^status:\|^title:\|^depends_on:\|^integrates_with:\|^complexity:\|^repo:" <docs>/tickets/*.md`. Fully read only the tickets being processed, plus the PRD/BRD and code needed to check them.
2. Check each ticket against the Ticket Rules (Aturan Tiket) section in `task-breakdown` and the `ticket-workflow` format:
   - **Per layer or per file** (separate migration, DTO, service, controller, test, Swagger) → merge into the endpoint/feature ticket that needs it.
   - **Too large** (several endpoints that aren't small CRUD, or several repos in one ticket) → split.
   - **Too small** (several `simple` TODO tickets on the same resource or page, same repo) → merge, max 3 per ticket, per the grouping rule in `task-breakdown`.
   - **BE ticket for an endpoint without `## Kontrak API`** → fill it from the PRD/BRD or existing code. Anything not written in any source becomes a question, not invented.
   - **FE ticket using a BE ticket's endpoint via `depends_on`** → change to `integrates_with`.
   - **Empty `complexity`** → fill per `ticket-workflow` criteria (unsure → `complex`).
   - **Generic File/Lokasi or nonexistent paths** → replace with real paths (check with glob/grep).
   - **AC without a negative side** → add from rules or exceptions in the PRD/BRD; if there's no basis, make it a question.
   - **Duplicate, or already covered by a DONE ticket** → propose deletion.
3. **Show the proposal; don't change files yet:**
   - Table: old ID → action (gabung / pecah / lengkapi / hapus / tetap) → resulting ID → short reason
   - Board after tidying, and ticket count before → after
   - Open questions
   Then ask for user approval.
4. **After approval:**
   - Merge: the resulting ticket uses the ID of the first ticket in the group; AC, File/Lokasi, `trace`, `depends_on` are merged without duplicates. Other ticket files are deleted. Add to the resulting ticket's Riwayat `- <YYYY-MM-DD HH:MM> <STATUS> — dirapikan: gabungan dari <ID>, <ID>`.
   - Split: new tickets use the next number after the last one, Riwayat `- <YYYY-MM-DD HH:MM> TODO — dirapikan: dipecah dari <ID>`.
   - Fill: change only the missing parts, Riwayat `- <YYYY-MM-DD HH:MM> <STATUS> — dirapikan: <apa yang dilengkapi>`.
   - Update `depends_on` and `integrates_with` in all tickets (including unprocessed ones) that reference removed IDs.
   - If a tracker is active and the ticket has `tracker_ref`, close the deleted ticket's issue/row with the note "digabung ke <ID>", and update the changed ones.
   - If a git repo, commit the ticket files: `chore(tickets): rapikan backlog`.
5. Final report: ticket count before → after, the latest board, and the next ticket to be picked.

## Re-review DONE ticket

1. Make sure the ticket is `DONE`. If not, say the ticket is still in the normal flow and stop.
2. Find the ticket's commit: `git log --grep "^<ID>:" --format="%h %s"` (multi-repo: in the repo named in the `repo` field). If not found, ask the user for the commit or range.
3. Call agent `ticket-reviewer` with the ticket path, the ticket repo's working directory, report path `<docs>/reports/<ID>/rereview-<n>.md`, and the instruction: "Nilai perubahan di commit <hash> (`git show --stat <hash>` dan `git show <hash>`), bukan working tree. Ini review ulang tiket yang sudah DONE."
4. Results:
   - `APPROVED` → add Riwayat `- <YYYY-MM-DD HH:MM> DONE — review ulang: APPROVED`.
   - `CHANGES_REQUESTED` → the original ticket stays DONE with Riwayat `- <YYYY-MM-DD HH:MM> DONE — review ulang: ada temuan, lihat <BUG-ID>`. Create a new `BUG-NNN` ticket (`type: bug`, `status: BUG`, `related: [<ID>]`, `complexity` per the findings) with the reviewer's findings as AC and File/Lokasi from that commit.
   - `BLOCKED` → show the reviewer's questions to the user.
5. Show the result. New BUG tickets are worked via `/noskill:tiket lanjut` or `feature-flow`.
