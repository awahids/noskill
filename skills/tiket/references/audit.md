# audit — quality audit of a folder or the whole repo

Read-only report; changes no code and no ticket. You do this yourself (not an agent) because it needs the whole picture. Arguments after `audit`: a folder/package to audit, or empty for the whole repo.

## 1. Map first
- Read `<docs>/project-profile.md` if it exists (stack, commands, folders), then the README, build/deploy config, dependency list, entry points (routes, handlers, jobs, CLI), and the tests.
- Find the expected load (one person running a script, or many users and processes at once) from the README or deploy config, judge scale against it, and say which load you assumed.
- Trace the main flows end to end (input in → stored → output out). Read fully the paths that touch user input, money, auth, data writes, background jobs, or state shared between processes. On a big repo go deep where a mistake costs most, and say which parts you did not read.

## 2. Look for
1. **Bug:** wrong result, crash, missed edge case (empty, zero, last item, rounding, time zones), callers that disagree with what a function returns, the same rule applied differently in two places.
2. **Risk:** security holes (injection, weak randomness, secrets in code, missing checks on user input, IDOR), data loss (errors swallowed, writes in the wrong order, no transaction).
3. **Scale:** check-then-write races, the same work done by every process, lists/caches that only grow, a query per item, O(n²) on big input, per-process state that must be shared.
4. **Missing test:** risky logic (branches, parsers, money, security, data writes) with no test that fails when it breaks — one good test, not coverage.
5. **Speed:** big slowdowns are problems; small wins are suggestions.
6. **Lean:** delete (dead code, unused options/flags), reuse (two helpers doing one thing — name the path to keep), stdlib/native instead of a dependency, yagni (one-implementation interface, pass-through wrapper), merge near-copies, split a function that does unrelated jobs (by job, never by line count).

## 3. Check before you report
- Every finding needs a concrete case: this input or situation → this wrong result. No case, no finding. No style taste, no vague worries.
- Before calling code unused, grep the whole tree including tests, fixtures, config, and string/dynamic references.
- A line marked `shortcut: <limit>, <upgrade>` is a decision, not a finding, unless the expected load already crosses its limit.
- Propose the smallest fix that works; prefer fixes that delete code.

## 4. Report (Bahasa Indonesia, short sentences, explain a technical term on first use)
- `Repo ini ...` (2–3 sentences) and the load you assumed.
- Findings in three groups, skipping empty ones: **Harus diperbaiki** (bug, security, data loss, breaks at expected load) · **Sebaiknya diperbaiki** (risky code without a test, real slowness, duplication, code that should not exist) · **Boleh nanti** (small speed-ups, shorter forms). Number across groups so the user can say "kerjakan 2 dan 5". At most 20; say how many smaller ones were left out.
- Each finding: **bold title** (`file:Lstart-end`), then **Apa ini**, **Masalah** (the concrete case), **Perbaikan** (smallest fix), **Kalau dilewati**.
- End with `Verdict:` (one line: sehat, or what to fix first), `Ramping: -<N> baris, -<M> dependensi mungkin` when lean findings exist, and `Belum dicek:` (what you did not read or run). Nothing found: `Sehat. Tidak ada yang perlu diperbaiki.` plus one line on what you checked.

## 5. After the report
Offer once: turn chosen numbers into tickets by running `feature-flow` in default mode (Must fix first; one ticket per bug, ID `FIX-NNN`). Don't create anything without an answer.
