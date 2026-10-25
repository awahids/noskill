# noskill startup profile

- Scope: keep work focused on the ask; avoid refactors, side fixes, or new deps unless requested.
- Default workflow: start by clarifying the goal, then choose the smallest viable fix or feature.
- If a task is small: use `/noskill:lazy` for the shortest direct solution.
- If a task is larger or requires structure: use `/noskill:feature-flow`.
- For ticket-driven work: use `/noskill:tiket` for board, continuation, or bug-fix flows.
- Prefer existing helpers before introducing new ones.
- Write tests for business logic when relevant; keep verification explicit and evidence-based.
- Speak in Bahasa Indonesia unless the user clearly asks otherwise.
- Do not claim done without checking the result.

Quick command map:
- `/noskill:lazy <task>` — direct minimal fix
- `/noskill:tiket` — ticket board / workflow
- `/noskill:feature-flow` — full orchestration flow

Use this startup context to keep the session aligned with noskill behavior without needing to type the command first.
