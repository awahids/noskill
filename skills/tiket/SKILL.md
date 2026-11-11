---
name: tiket
description: Shortcut for the ticket board — /noskill:tiket [board] · lanjut [catatan] · fix DESKRIPSI · rapikan [ID] · rapikan review ID · utang · audit [folder].
argument-hint: "[board | lanjut [catatan] | fix DESKRIPSI | rapikan [review] [ID] | utang | audit [folder]]"
disable-model-invocation: true
---

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.

Arguments: $ARGUMENTS

Pick the action from the first word, then read only that action's file in this skill's `references/` folder:

| First word | Action |
|---|---|
| empty or `board` | Show the board without changing files — `references/board.md` |
| `lanjut` | Resume the ticket flow from file status; the remaining words are the user's note/answer for HOLD tickets — `references/lanjut.md` |
| `fix` | Run skill `feature-flow` in **default mode** with the remaining words as the request. If it's empty or too vague to write acceptance criteria from, ask once, briefly, first. |
| `rapikan` | Tidy tickets or re-review a DONE ticket; the remaining words are its arguments — `references/rapikan.md` |
| `utang` | Read-only ledger of `shortcut:` comments in the code — `references/utang.md` |
| `audit` | Read-only quality audit of a folder or the whole repo; the remaining words are the folder — `references/audit.md` |

Anything else: show the usages above in one short list and ask which one was meant.
