# Multi-Repo

Baca file ini hanya saat fitur menyentuh lebih dari satu repo.

For one feature touching several repos (e.g. `api` NestJS, `web` Vue, `mobile` Flutter).

1. **Docs repo:** the repo this session runs in. PRD, BRD, and all tickets live only in this repo's `<docs>/` — one board for the whole feature. Other repos get no noskill folder.
2. **Repo list** is in the `## Repo` section of `<docs>/project-profile.md`: short name, path relative to the docs repo, and its profile file. Other repos' profiles are stored in the docs repo as `<docs>/project-profile-<nama>.md` (run `project-profile` for that repo). If a repo path doesn't exist on this machine, ask the user — don't guess.
3. **One ticket = one repo.** A ticket has field `repo: <nama>` and `File/Lokasi` relative to that repo's root. A change needing two repos is split into two tickets: the `api` ticket holds the Kontrak API, and the `web` ticket sets `integrates_with` to that `api` ticket — worked concurrently, each verified against the contract with mocks; the real `web`↔`api` flow is checked in Stage 6.
4. **Working branch** with the same name is created in every repo that has tickets, before the first ticket in that repo is worked.
5. **When calling agents**, send working directory = that ticket's repo path (or its worktree in parallel mode, created with `git -C <path repo> worktree add …`) and that repo's profile path. The ticket path stays in the docs repo.
6. **Commit code** in the ticket's repo (`<ID>: <title>`). Ticket file updates are committed in the docs repo.
7. **Cross-repo check:** in Stage 6, start the environment from the `api` repo's working branch and run the `web` repo's E2E suite against it. If it can't run here, tell the user and list it under "belum dicek" in the PR.
8. Tickets in different repos never overlap `File/Lokasi`, so in parallel mode they can run concurrently as long as `depends_on` is met — including BE–FE pairs via `integrates_with`.
