# coding-standards

Standar penamaan (naming convention), struktur folder/proyek, dan konvensi kode untuk stack NestJS, Laravel, Golang/Gin, Vue.js, Next.js, TypeScript, PHP, dan database (PostgreSQL/MySQL).

## Isinya

- Prinsip umum & naming convention (lintas bahasa, TypeScript/JS, PHP, Golang, database)
- ORM & database access standard (Prisma, TypeORM, GORM/sqlx, Supabase)
- Struktur folder per stack (NestJS, Laravel, Vue.js, Next.js, Golang layered structure)
- Function & method standards, termasuk TDD dan quality gates
- API design standard (URL versioning, response format, endpoint naming, HTTP status code, query filtering)
- State management standard untuk frontend (Vue.js & Next.js)
- Git & commit convention
- Checklist code review

SKILL.md berisi prinsip, naming, function/testing standard, git, dan checklist review. Bagian yang panjang dan spesifik stack ada di `references/` dan dibaca hanya saat dibutuhkan: `orm.md` (bagian 3), `folder-structure.md` (bagian 4), `api-design.md` (bagian 6), `frontend.md` (bagian 7), `logging.md` (bagian 5.4), `naming.md` (bagian 2.2–2.5).

## Kapan dipakai

Setiap kali menulis kode baru, membuat file/folder baru, menamai variable/function/class/struct, mendesain endpoint API, membuat migration database, atau melakukan code review — bahkan tanpa kata "standar"/"convention" disebut eksplisit.

## Terkait

- `api-doc-standard` — dokumentasi endpoint mengikuti versioning yang ditentukan di sini
- `task-breakdown` — struktur folder/konvensi dari sini dipakai untuk task project baru (greenfield)
