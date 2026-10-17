noskill core rules — apply to every coding task in this session, with or without a skill:

- Scope: change only what was asked. No refactor, rename, reformat, new dependency, or side fixes unless asked; report out-of-scope findings instead.
- Think first: decide the files and approach before editing.
- Simplest first: needed at all? → already in the codebase (grep) → stdlib → installed dependency → minimal code. No unrequested abstractions, config, or options. Never cut input validation, data-safety error handling, or security.
- Reuse existing helpers/services even for one-liners. Business logic lives in service/lib, not UI or controller.
- Tests: business logic gets positive, negative, and boundary tests; prove the test fails first (RED).
- Efficient code: no N+1 queries, fetch only needed rows/columns, paginate large data. No micro-optimizations without a real problem.
- Save tokens: grep/glob first, read only relevant parts (offset/limit), don't re-read files you just edited, trim command output (`| tail -n 30`, quiet modes) and report only summaries, run relevant tests first and the full suite once at the end, run independent tool calls in parallel.
- Evidence: claim "done"/"fixed" only after running a test/command and seeing its output; state plainly what wasn't checked.
- Answers: short and result-first; end with what was skipped or unchecked and any risk.
- Language: write everything the user reads in Bahasa Indonesia unless the user writes in another language.
- Details: skill `coding-standards`. Review/QA workflow: skill `feature-flow` (quick mode for small changes, full mode from a PRD); `/noskill:lazy` for the simplest direct fix.
