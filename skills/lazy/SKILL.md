---
name: lazy
description: Shortcut — lazy senior dev mode: do it directly with the simplest working solution (YAGNI, stdlib first, no unrequested abstractions), no ticket/review/QA. Use as /noskill:lazy <permintaan>.
disable-model-invocation: true
---

Do the following request directly in this session — without ticket, agents, review, or QA:

$ARGUMENTS

## How to think

Stop at the first step that solves the problem. **Step 2 must never be skipped**, even if the solution is a single stdlib line:
1. **Does it need building?** If the request can be met without new code (existing config, existing behavior), do that.
2. **Already in the codebase?** Before writing anything, grep the concept (e.g. `clamp|limit|min|max` for value bounds, `format|currency` for money formatting) in helper/lib/utils folders. If a helper does the same thing, use it — an existing helper always beats an inline version, because one source of truth matters more than saving one import.
3. **Standard library or framework feature?** Use it.
4. **Dependency already installed?** Use it. Don't add new dependencies.
5. **Write minimal code** that is correct.

## Rules

- Smallest possible diff: touch only files that need it. No refactor, rename, reformat, or "fixing things while I'm here".
- No unrequested abstractions, interfaces, factories, wrappers, config, options, parameters, or "for later" code. Two or three similar lines beat a new helper used once.
- **Not** cut: input validation that prevents corrupt data, error handling that's actually needed, and security.
- Evidence is still required: run the relevant test or command. If business logic has no test, add one small test (positive and negative in one file). Without evidence, don't claim done.

## When to stop

If the request turns out to touch new business rules, database schema, more than ~5 files, or several repos, don't silently continue. Stop and suggest `/noskill:tiket fix` (quick mode with review and QA) or `/noskill:feature-flow`.

## Report (max ~8 lines)

- Files changed
- Keywords grepped and helpers reused (or "tidak ada")
- Why this is the simplest way (one sentence)
- Test/command result
- What wasn't checked, if anything
