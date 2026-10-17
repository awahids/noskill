<!-- Part of the coding-standards skill: Git, environment & secrets, changelog. -->
# Coding Standards — Git, Secrets, and Changelog

## 8. Git & Commit Convention

### 8.1 Branch & Commit

Branch: `feature/order-checkout-flow`, `fix/user-login-null-pointer`, `hotfix/payment-webhook-timeout`, `refactor/order-service-cleanup`

Commit (Conventional Commits): `<type>: <short description, present tense>`
Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`

### 8.2 Environment & Secrets

- **`.env` is never committed** — it must be in `.gitignore` from the project's first commit. If the project already committed `.env`, remove it from history (`git filter-repo`/BFG) and **rotate every secret that was exposed** — don't just remove it from the latest commit (it is still in git history).
- **Always commit `.env.example`** to the repo — containing the required variable names with placeholder/dummy values (`DATABASE_URL=postgres://user:pass@localhost:5432/dbname`), so others (or yourself 6 months later) know which env vars to fill without guessing from the code.
- **Secrets in CI/CD and production** are stored in the platform's secret manager (GitHub Actions secrets, Vercel/Railway env vars, etc.), not hardcoded in committed config files.
- **Rotate secrets** when: a team member who had access leaves, there is a sign of a leak (exposed logs, accidentally shared screenshot), or periodically for sensitive credentials (payment gateway, service-to-service keys) per a policy reasonable for the project's scale.
- For credentials used across systems (e.g. the `X-Service-Key` pattern in backend-to-backend integrations) — store them in each system's `.env`; don't hardcode them in code even if "it's only internal".

### 8.3 Changelog

For projects with releases/versions that need communicating (used by other people, released to production regularly, or open source) — generate `CHANGELOG.md` from commit history, not written manually from memory:

- Since commits already follow Conventional Commits (8.1), the changelog can be generated automatically (`conventional-changelog`, `git-cliff`, or a platform's built-in changelog generator such as GitHub Releases) — grouped automatically by type (`feat` → "Features", `fix` → "Bug Fixes", etc.)
- Commits with `BREAKING CHANGE:` in the footer or `!` after the type (`feat!:`) are clearly marked as breaking in the changelog — in line with the breaking change checklist in `references/api-doc.md`
- For small/internal projects not released to outside parties, a changelog is optional — don't force it if nobody reads it
