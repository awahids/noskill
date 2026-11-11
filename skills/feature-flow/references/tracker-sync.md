# Tracker Sync (opsional)

Baca file ini hanya bila `<docs>/project-profile.md` berisi `tracker: github` atau `tracker: notion`.

If `<docs>/project-profile.md` contains `tracker: github` or `tracker: notion`, the ticket board is copied to that tracker. One-way: ticket files remain the source of truth; the tracker is only a mirror.
- **When:** when a ticket is created (Stage 4 or Plan), and when a ticket becomes DONE, BUG, or HOLD. Other status changes aren't synced, to save tool calls.
- **GitHub Issues:** one issue per ticket. Title `<ID>: <title>`, body contains the AC, label `noskill:<status>`. Issue is closed on DONE.
- **Notion:** one row per ticket in database `notion_database` (columns ID, Judul, Status). Look up an existing row by ID before creating a new one.
- Store the issue number or page URL in the ticket frontmatter (`tracker_ref:`) so later updates don't create duplicates.
- If the tracker tool is unavailable or fails, continue the flow and mention it once to the user. Sync must never stop the work.
