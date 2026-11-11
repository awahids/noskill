# utang — shortcut debt ledger

Read-only. Lists every deliberate shortcut in the code so a deferral cannot quietly become permanent. Changes nothing unless the user asks for the file.

Convention (from `coding-standards` principle 9 and `ticket-implementation`): `shortcut: <the limit>, <when to upgrade>` in a code comment.

1. Scan the working tree, skipping `.git` and everything ignored:
   `git grep --no-index --exclude-standard -nE '(#|//|/[*]|--) ?shortcut:'` (add other comment prefixes if the stack uses them). If the user names another marker word (`utang TODO`), grep for that word instead.
2. Each hit is one row; skip hits that are not a deferral (prose that merely mentions the convention). Group by file:
   `<file>:<line> — <what was simplified>. batas: <the limit>. upgrade: <trigger to revisit>.`
3. A marker that names no limit or no upgrade trigger gets the tag `tanpa-pemicu` — those rot silently. For rows the user cares about, add `git blame -L<line>,<line>` for the owner.
4. Cross-check the board: if a shortcut appears in a DONE ticket's developer report under "Dilewati / belum dicek", name that ticket.
5. End with `<N> penanda, <M> tanpa pemicu.` Nothing found: `Tidak ada utang shortcut.`
6. Offer: write the ledger to `<docs>/shortcut-debt.md`, and/or turn the `tanpa-pemicu` rows or any whose limit is already crossed into tickets (`/noskill:tiket fix`). Do neither without an answer.
