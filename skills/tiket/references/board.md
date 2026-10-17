# board — show the ticket board

Show the board from `<docs>/tickets/` without changing any file:

1. Get all ticket statuses at once: `grep -H "^status:\|^title:\|^rounds:\|^repo:" <docs>/tickets/*.md`. Don't read ticket files one by one except for HOLD tickets.
2. Show one table ordered TODO · IN_PROGRESS · REVIEW · QA · BUG · HOLD · DONE, with columns ID, title, and rounds (plus a repo column if any ticket has a `repo` field).
3. For HOLD tickets, read the last line of `## Riwayat` and show the question awaiting the user's answer.
4. **Duration per stage.** Compute with a command, not in your head:
   ```bash
   python3 - <docs>/tickets <<'PY'
   import sys, re, glob, os
   from datetime import datetime as D
   stage = {"IN_PROGRESS": "dev", "BUG": "dev", "REVIEW": "review", "QA": "qa"}
   for f in sorted(glob.glob(sys.argv[1] + "/*.md")):
       ev = [(D.strptime(t, "%Y-%m-%d %H:%M"), s) for t, s in re.findall(r"^- (\d{4}-\d\d-\d\d \d\d:\d\d) ([A-Z_]+)", open(f).read(), re.M)]
       m = {"dev": 0, "review": 0, "qa": 0}
       for (a, s), (b, _) in zip(ev, ev[1:]):
           if s in stage: m[stage[s]] += (b - a).total_seconds() / 60
       if ev: print(os.path.basename(f)[:-3], ev[-1][1], *(round(m[k]) for k in ("dev", "review", "qa")), sep="\t")
   PY
   ```
   Output is minutes per ticket for the developer stage (including revision/BUG), review, and QA. Waiting time in TODO and HOLD isn't counted; time an FE ticket waits for its BE ticket counts toward QA. Old tickets whose Riwayat has no time don't appear. If `python3` isn't available, skip this step and say so.
   Show a duration table for DONE tickets (dev · review · QA · total), the average per stage, and the slowest stage — that's the next optimization candidate.
5. Close with one line: count per status and the next ticket to be picked per the order in skill `ticket-workflow`.

If `<docs>/tickets/` doesn't exist, say there are no tickets yet and suggest `/noskill:tiket fix <deskripsi>` or skill `feature-flow`.
