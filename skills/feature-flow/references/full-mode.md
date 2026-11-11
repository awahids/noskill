# Full mode — Stages 1–4

Baca file ini hanya saat user meminta PRD/BRD/ADR (full mode). `<docs>` = folder dokumen noskill seperti di `SKILL.md`.

## Stage 1–2 — PRD (Product Manager) — full mode only

Agent `product-manager` cannot talk to the user, so you relay in two calls (ERP/WMS domain design from `erp-domain-design` is folded into its questions):
1. Call `product-manager` mode `QUESTIONS` with the user's request verbatim, PRD path `<docs>/prd.md`, and the profile path. Ask the user all returned questions at once — questions marked `[pilihan: …]` through the interactive choice tool if available, the rest as a numbered list. Wait for the answers.
2. Call the same agent (SendMessage to its ID) with mode `WRITE` and the answers. If the user asked for "PRD dari kode yang ada", use mode `REVERSE` instead of these two steps. If the user said to skip questions, go straight to `WRITE` with assumptions marked.

**Gate:** show the PRD summary and its `[asumsi]` list, and ask the user to approve the PRD. Revision notes go back to the same `product-manager` agent (mode `WRITE` with the notes).

## Stage 2b — Architecture Review (CTO)

Call agent `cto` mode `ARCH_REVIEW` with the PRD path, profile path(s), ADR folder `<docs>/adr/`, and report path `<docs>/reports/_cto/arch-<n>.md`.
- `GO` → continue to Stage 3.
- `GO_WITH_NOTES` → show the ADR titles and decisions (one line each), then continue unless the user objects.
- `NO_GO` → show the CTO's questions/required PRD changes to the user; send the answers to `product-manager` (mode `WRITE` with notes), get PRD approval again, then re-run `cto`. After a second `NO_GO`, stop and let the user decide.

From here on, pass the ADR folder to `brd-tracer`, `task-planner`, and every developer and reviewer call.

## Stage 3 — BRD Traceability

**Skip this stage if level = tanpa BRD**; go straight to Stage 4.

Call agent `brd-tracer` with: PRD path, domain prefix, level (full/ringkas), ADR folder, and the Stage 0 context answers. Output goes to `<docs>/01-business/` … `<docs>/05-testing/`.

If the agent returns a list of open questions, ask the user, then call it again with the answers.

**Gate:** show a summary (count of BR/US/AC/TECH/TC) and ask for user approval.

## Stage 4 — Tickets

First hold the ticket meeting (`meeting.md` in this folder), with the PRD, BRD, and ADR documents' owners as attendees. Then call agent `task-planner` with: PRD path, BRD folder (or the note "tanpa BRD"), ADR folder, ticket prefix, and codebase path (multi-repo: the `## Repo` table from the profile). Output is ticket files `<docs>/tickets/<ID>.md` with status `TODO`.

**Gate:** show the board (see `ticket-workflow` Board section) and ask for approval. If there are per-layer tickets (separate migration/DTO/test), merge them before starting. For BE tickets with an FE counterpart, also show their Kontrak API — the contract is approved together with the ticket list. Also ask the run mode and offer the fresh-session tip exactly as in Plan steps 4–5 of `SKILL.md`.
