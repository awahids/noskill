---
name: ticket-implementation
description: >-
  Shared procedure for the developer agents (developer, backend-developer, frontend-developer): implement one ticket within scope, TDD with RED evidence, quality gates, report READY_FOR_REVIEW or BLOCKED.
user-invocable: false
---

# Ticket Implementation

noskill docs folder: `${user_config.docs_dir}` — written as `<docs>` below. If that value still appears literally (not substituted), use `docs/noskill`.
Write reports, tickets, and documents in Bahasa Indonesia; keep verdict keywords in English as listed.
Implement **one ticket** given by the orchestrator, following the `coding-standards` skill (including `references/api-doc.md` in that skill if the ticket touches an endpoint).

If the orchestrator gives a **working directory** (the ticket's repo in a multi-repo feature, or the ticket's worktree in parallel mode), do all code reads, writes, and commands there: use paths under that directory and run commands with `cd <direktori> && …`. Do not touch the main checkout. The ticket file is still read from the path given.

If a project profile exists — the path given by the orchestrator (multi-repo: the ticket repo's profile), or `<docs>/project-profile.md` — read it first and use the commands, structure, and helpers recorded there — do not re-explore what the profile already covers. If its content turns out wrong (command fails, path missing), mention it in the report so the orchestrator refreshes the profile.

## Mandatory rules

- **Full report to a file, short answer.** Before answering, always write the full report to a file (step 8) — without a report file, the ticket cannot be reviewed. The answer to the orchestrator is at most 6 lines and ends with `Laporan: <path>`.
- **Only change what the ticket asks.** Files you may change are those in `## File/Lokasi` plus their test files. If you must touch another file, that is allowed only if the AC cannot be met without it, and the reason must be written in the report. **Using (importing/calling) a helper from another file is not changing that file** — that is always allowed.
- **Forbidden** (unless the ticket asks for it): refactoring, renaming, reformatting, moving code, changing code style, upgrading/adding dependencies, deleting other code, or "fixing things along the way" in surrounding code. Problems outside the ticket are just noted in the report.
- **Think first, then write.** Do not start editing before the plan in step 3 is done.
- **Reuse is mandatory.** If a helper/service already does the same thing, use it — even if the replacement logic is just one line. A single source of truth matters more than saving one import. Rewriting existing logic is a violation, not a simplification.
- **API contract.** BE ticket: the implementation must match `## Kontrak API` exactly (path, fields, status codes, error codes). FE ticket with `integrates_with`: work from the contract in that BE ticket — do not wait for BE to finish; if BE does not exist yet, FE tests use mocks/stubs per the contract. If the contract turns out incomplete or wrong, do not change it yourself — report `BLOCKED` with the proposed change.
- **ADRs are binding.** If the orchestrator gives an ADR folder, read the ADRs relevant to the ticket. If the ticket cannot be done without breaking one, report `BLOCKED` — do not override it.
- **Simplest approach first** per `coding-standards` principle 9. Do not create new abstractions, layers, config, or options if a simple solution already meets the AC.

## Steps

**Follow-up revision.** If the orchestrator sends you review notes or a bug report (you are the same agent that worked on this ticket before), do not re-read the ticket, profile, or files you already read. Work only on the points in those notes, re-run only the tests and gates related to the revision changes, then report with the same verdict format.


1. Read the full ticket file, including `## Riwayat`. If this is a revision (review notes exist) or `status: BUG` (bug report exists), work only on the points in that latest note.
2. If the ticket has `## Catatan`, start there: helpers, example files, and tests listed there were already found by the ticket author — use them directly, do not grep the same things again. Then read the code in `## File/Lokasi` and around it. For concepts **not** covered by the notes, **search first** (grep) for helpers, services, patterns, and dependencies that already do something similar — grep the concept, not just function names (e.g. `clamp|limit|min|max` for value limiting, `format|currency` for money formatting). If one exists, use it, do not write a new version — an existing helper wins over an inline version, even if the inline version is one stdlib line. New business logic goes in a reusable, testable layer (service/usecase/`lib`), not in a controller or UI component (`coding-standards` principle 4).
3. **Make a plan before writing code:**
   - Files to change (must match `## File/Lokasi`)
   - The chosen approach, and the simpler alternatives considered with the reason they are not enough
   - For BUG tickets: invoke the `debug-assistant` skill via the Skill tool, then follow its flow — reproduce the bug report first, find the root cause, then plan the smallest fix at the origin of the problem
4. Implement per the plan. For logic with business rules, write tests first (TDD in `coding-standards` 5.1) — **positive, negative, and boundary** for each AC — and run **only that test file** before implementing to prove the tests fail (RED). Keep the output for the report.
5. Check your own diff with `git diff` and `git status`. Revert every line not needed for the ticket's AC: format changes, renames, unplanned files.
6. Run quality gates (`coding-standards` 5.2) **once, limited to what was touched**, using the fast command variants from the profile if present (Typecheck cepat, Lint file tertentu, Test terkait file yang diubah): typecheck, lint for changed files only, tests for the ticket's test files and tests related to changed files (e.g. `jest --findRelatedTests <file>`, `go test ./<paket>/...`), then the `## Cara Verifikasi` steps. The full suite is not run here — the orchestrator runs it once at the end. Everything must pass before reporting; if something fails, fix it and re-run only the failed command.
7. **Do not commit, do not change the ticket file.** The orchestrator commits and moves the status.
8. **Mandatory: write the report to a file** before answering — the path from the orchestrator, or, if none is given, `reports/<ID>/dev-<putaran>.md` in the docs folder that is the **same as the ticket file's** (for ticket `docs/noskill/tickets/X.md`: `docs/noskill/reports/X/`) — always in the main checkout, not in the working directory/worktree (`mkdir -p` the folder first). Then answer the orchestrator in at most 6 lines (see below).

Write the **full report** to the report path given by the orchestrator (default `<docs>/reports/<ID>/dev-<putaran>.md`, putaran = `rounds` + 1), containing a summary of command output (pass/fail counts, names of failed tests, key error lines), not full logs. The reviewer reads this report from the file.

Your answer to the orchestrator is **at most 6 lines**: first line the verdict, then a very short summary (files changed, test results), then `Laporan: <path>`. Do not repeat the report content in the answer — every answer line enters the orchestrator's context for every ticket.

Verdict:
- `READY_FOR_REVIEW` — report content: the plan from step 3 (including simpler alternatives considered, keywords grepped to find helpers with their results, and helpers reused), list of tests per AC with their type (positive/negative/boundary), changed files with reasons for files outside `## File/Lokasi`, summary of changes per AC, RED test output before implementation, quality gates and Cara Verifikasi output (evidence, not claims), and problems outside the ticket that were found but not changed
- `BLOCKED: <alasan>` — only if you cannot resolve it yourself: ambiguous/conflicting requirements, missing access/environment, a business decision is needed. Specific questions for the user go directly in the answer (not only in the report).
