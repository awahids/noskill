# Ticket meeting (rapat tiket)

Hold this every time tickets are about to be written: in Plan after step 1 (default mode), and in Stage 4 before calling `task-planner` (full mode). Everyone who will touch the tickets gives input once, before the split is final — like a refinement meeting. In `/noskill:kantor` they all walk to the meeting room.

## Attendees
- `task-planner` (the tech lead) — always, even when you write the tickets yourself (≤ 3).
- `ticket-reviewer` — always (testability of the AC).
- `backend-developer` if a planned ticket has `layer: be`; `frontend-developer` if `fe`; `developer` if neither.
- Full mode, for the documents that exist: `product-manager`, `cto`, `brd-tracer`.
- You (`feature-flow`) chair it.

## Steps
1. **Draft the split** (ticket titles + one-line File/Lokasi each, from your code reading in Plan step 1 or from the PRD/BRD) — a draft, not ticket files yet.
2. **Open the meeting:** one write of `<docs>/activity.json`: `{"agent": "feature-flow", "status": "meeting", "stage": "Rapat tiket", "task": "<short line>", "ticket": null, "meeting": ["task-planner", "ticket-reviewer", "backend-developer", …], "at": "<now>"}`. `meeting` lists the attendee agent names (not `feature-flow`). Do **not** overwrite this file until the gate: the planner call and every other step below happen while the meeting is open. A meeting left open ends by itself after 30 minutes.
3. **One round, all attendees in parallel** (all calls in the same message). Each call says `Mode RAPAT` and sends: the request (or PRD/BRD paths), your draft split, the profile path, `<docs>/lessons.md` if it exists, and that role's question:
   - `task-planner`: is the split the fewest tickets that deliver the request? merge or split anything? dependency order?
   - developers: feasible as drafted? which existing helpers/patterns to reuse (grep first)? contract or data-shape risks? effort per ticket (`simple` or `complex`)?
   - `ticket-reviewer`: can every AC be verified without a database or server? which negative or boundary AC is missing?
   - `product-manager`: is it MVP, any ticket not backed by the PRD? `cto`: conflict with an ADR or a non-functional need? `brd-tracer`: gaps in `trace`?
   Each answers in **at most 8 lines**: `Setuju` or the specific change, then `Risiko:` and `Asumsi:` lines (`—` if none). They write no file and change nothing. Never pass `model`.
4. **Minutes:** write `<docs>/reports/_rapat/rapat-<n>.md` (≤ 30 lines, Bahasa Indonesia): `## Peserta`, `## Keputusan` (what changes in the split, per ticket), `## Risiko`, `## Asumsi`, `## Pertanyaan terbuka`. Apply the decisions to the split. Put reuse hints and risks that concern one ticket into that ticket's `## Catatan`; put assumptions the AC rely on into its `## Deskripsi`.
5. **Disagreements:** one round only. If attendees contradict each other and the facts (code, PRD) don't settle it, list it under `Pertanyaan terbuka` and ask the user at the gate. Never spend a second round.
6. Continue: write the tickets (or call `task-planner`), then the gate. The gate's `waiting_user` write ends the meeting.
