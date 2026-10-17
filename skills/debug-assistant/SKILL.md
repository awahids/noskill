---
name: debug-assistant
description: >-
  Structured debugging: reproduce → isolate → root cause → fix → verify with evidence, incl. external integrations (WMS API, n8n, Power Automate, Microsoft Graph). Use on errors, stack traces, bugs, failed API calls, "kok error", "gak jalan".
---

# Debug Assistant

Use this structured flow whenever helping debug, instead of guessing a fix right away. Goal: find the root cause, not just remove the symptom.

## Debugging Flow

### 1. Reproduce
Before concluding anything, make sure the problem can be reproduced:
- Ask for the exact steps the user took (request, input, environment)
- If there's an error message/stack trace, ask for the full text, not truncated
- Ask: does it happen consistently, or only sometimes? (sign of a race condition/timing issue)
- For APIs: ask for the full example request (method, headers, body) and the response received

### 2. Isolate
Narrow the problem area before guessing the cause:
- When did it last work normally? What changed since? (new deploy, dependency update, config change)
- Does it happen in all environments or only one (staging vs production, local vs server)?
- If an external integration is involved (WMS API, Microsoft Graph, n8n, Power Automate) — isolate whether the problem is in our request, their response, or in between (network/timeout/auth)

### 3. Diagnose
Check the most likely first, in priority order:
1. **Input/validation** — is the incoming data actually wrong/not as expected?
2. **Logic/business rule** — wrong condition, off-by-one, null/undefined handling
3. **State/data** — database data was already inconsistent before this request
4. **Configuration/environment** — different env var, wrong secret, different endpoint URL
5. **External/integration** — another service down, rate limit, expired auth token
6. **Infra** — memory, timeout, concurrency

For each hypothesis, state a **quick way to verify** it (extra logging, DB query, manual curl) before changing code.

**Specific diagnosis techniques (use according to bug type):**

- **Root-cause tracing** — if the bug shows up at point A, don't assume A is where it lives. Trace back: where did this wrong data/state come from? Follow the call stack or data flow backwards until you find the point where the value **first became** wrong — not where it was first *seen* wrong. Example: null error on `order.total_amount` at render — don't just add a null-check there; trace why `total_amount` can be null (calculation in the service? default value lost in a migration? race condition on insert?).
- **Defense-in-depth** — after the root cause is found and fixed at the origin, consider whether **additional validation layers** are needed at other vulnerable points (not a replacement for the root fix, but a safeguard in case other unknown paths produce a similar condition). Don't stop at a single fix point if this bug type can arise from many paths.
- **Condition-based waiting** (for race conditions/timing issues) — if the symptom is "sometimes fails, sometimes works" and timing-related (async, job queue, event), **don't** fix it with a fixed `setTimeout`/`sleep`. Instead wait for the **actual condition** that must be met (status polling, event listener, a promise that resolves when the work is done) — a fixed delay only hides the race condition, it doesn't remove it.

### 4. Fix & Verify
- Fix the root cause, not the symptom (e.g. for a race condition, don't just add `setTimeout` — see *condition-based waiting* above)
- After the fix, re-verify the reproduce scenario from step 1
- Check whether the fix could affect other parts (side effects)

> **Evidence over claims — never claim "fixed" without evidence.** Before telling the user the bug is resolved:
> - Re-run the exact same reproduce scenario from step 1 and show the result (not just "it should be correct based on this code change")
> - If there are tests, run them and show they pass — not the assumption "tests will pass because the logic is right"
> - If you can't run/reproduce directly (e.g. the required environment isn't available right now), say so explicitly to the user — never disguise uncertainty as certainty
> - "Probably fixed" and "verified fixed" are two different claims — never use language that makes one sound like the other

### 5. Prevent Recurrence (optional but recommended)
- Is extra logging needed at this point for next time?
- Is a new test case needed so this regression is caught automatically?
- If this was a configuration/process mistake, do docs/the deploy checklist need updating?

## Output Format When Helping Debug

When helping the user, structure the answer in sections:
1. **Possible causes** (ordered from most likely)
2. **How to verify** each possibility (specific: command, query, logs to check)
3. **Fix recommendation** after the cause is confirmed — don't give a fix before the cause is clear, unless the user only needs a temporary quick patch (state explicitly if it's a stopgap, not a permanent solution)

## Special Case: External API Integration
Since work often involves WMS API, n8n, Power Automate, Microsoft Graph — for these cases always check first:
- Is the curl/HTTP request correct (headers, auth, body format)?
- Does the external error response have a code/message that directly points to the problem (don't assume before reading the full response body)?
- Is this a new problem, or is the external service actually having an issue (check its status page if any)?

## Core Principle

**Evidence over claims.** This principle applies at every stage of the debugging flow, not only in Fix & Verify: never conclude a cause without evidence (logs, query results, command output), and never claim a problem is solved without re-running the failing scenario. "This seems to be the cause" and "confirmed this is the cause via [evidence X]" are two different confidence levels — always be clear which one you're stating.
