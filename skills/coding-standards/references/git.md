<!-- Bagian dari skill coding-standards: Git, environment & secrets, changelog. -->
# Coding Standards — Git, Secrets, dan Changelog

## 8. Git & Commit Convention

### 8.1 Branch & Commit

Branch: `feature/order-checkout-flow`, `fix/user-login-null-pointer`, `hotfix/payment-webhook-timeout`, `refactor/order-service-cleanup`

Commit (Conventional Commits): `<type>: <deskripsi singkat, present tense>`
Tipe: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`

### 8.2 Environment & Secrets

- **`.env` tidak pernah di-commit** — wajib ada di `.gitignore` sejak commit pertama project. Kalau project sudah terlanjur commit `.env`, hapus dari history (`git filter-repo`/BFG) dan **rotate semua secret yang sempat ke-expose**, jangan cuma dihapus dari commit terbaru (masih ada di history git).
- **Selalu sertakan `.env.example`** di-commit ke repo — isinya nama variable yang dibutuhkan dengan value placeholder/dummy (`DATABASE_URL=postgres://user:pass@localhost:5432/dbname`), supaya orang lain (atau diri sendiri 6 bulan kemudian) tahu env var apa saja yang perlu diisi tanpa harus menebak dari kode.
- **Secret di CI/CD dan production** disimpan di secret manager platform (GitHub Actions secrets, Vercel/Railway env vars, dll), bukan hardcoded di file config yang ikut ter-commit.
- **Rotasi secret** setelah: ada anggota tim yang keluar dan sempat punya akses, ada indikasi kebocoran (log ke-expose, screenshot ke-share tidak sengaja), atau secara berkala untuk kredensial sensitif (payment gateway, service-to-service key) sesuai kebijakan yang wajar untuk skala project.
- Untuk kredensial yang dipakai lintas sistem (contoh pola `X-Service-Key` di integrasi antar backend) — simpan di `.env` masing-masing sistem, jangan hardcode di kode meskipun "cuma internal".

### 8.3 Changelog

Untuk project yang punya rilis/versi yang perlu dikomunikasikan (dipakai user lain, dirilis ke production secara berkala, atau open source) — generate `CHANGELOG.md` dari histori commit, bukan ditulis manual dari ingatan:

- Karena commit sudah mengikuti Conventional Commits (8.1), changelog bisa di-generate otomatis (`conventional-changelog`, `git-cliff`, atau built-in changelog generator dari platform seperti GitHub Releases) — kelompokkan otomatis per tipe (`feat` → "Features", `fix` → "Bug Fixes", dst)
- Commit dengan `BREAKING CHANGE:` di footer atau `!` setelah tipe (`feat!:`) ditandai jelas di changelog sebagai breaking — selaras dengan checklist breaking change di `references/api-doc.md`
- Untuk project kecil/internal yang tidak dirilis ke pihak luar, changelog opsional — tidak perlu dipaksakan kalau tidak ada yang membacanya
