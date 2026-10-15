---
name: task-breakdown
description: >-
  Memecah PRD atau dokumen BRD menjadi task actionable per fase dengan dependency, acceptance criteria, cara verifikasi, dan kolom Trace ke US/AC/TECH; menyesuaikan struktur codebase yang sudah ada. Gunakan saat user minta "pecah jadi task", "breakdown PRD", atau backlog dari PRD.
---

# PRD to Task Breakdown

Mengubah PRD menjadi task list yang siap masuk ke tracker (Notion/Jira/Trello/GitHub Issues) atau langsung dikerjakan. Beda dari `prd-writer` (dokumen requirement) — skill ini fokus ke **eksekusi**: apa yang harus dikerjakan, dalam urutan apa, dan siapa/sistem mana yang terdampak.

## Langkah 1: Pahami Konteks Project

**Sebelum membuat task, tentukan dulu:**

1. **Project baru murni (greenfield)** atau **integrasi/penambahan ke project existing**? Cek bagian Architecture di PRD — kalau ada penyebutan sistem lain yang sudah berjalan (repo existing, stack yang harus disamakan, endpoint yang sudah ada), ini kasus integrasi.
2. Kalau **integrasi ke existing project**, task **wajib mengikuti struktur folder, pola kode, dan konvensi yang sudah disebutkan PRD-nya sebagai existing** — bukan membuat task "setup project baru dari nol". Kutip path/file konkret yang disebut PRD (contoh: `server/internal/delivery/handlers/canteen_proxy.handler.go`, pola `stores/attendance.js`) sebagai referensi langsung di task, bukan folder generik seperti `src/handlers/`.
3. Kalau PRD tidak menyebutkan detail struktur existing secara spesifik tapi menyebut "terintegrasi ke sistem X", **tanyakan ke user** apakah ada akses ke codebase existing tersebut (path lokal, repo) supaya task-nya presisi — jangan menebak struktur folder yang tidak disebutkan.
4. **Cek apakah sudah ada dokumen `erp-brd-traceability`** (US-xxx, AC-xxx, TECH-xxx) untuk fitur ini. Kalau ada, dokumen itu jadi sumber utama breakdown — lihat aturan traceability di Langkah 4. Kalau tidak ada, sumbernya PRD saja.
5. Identifikasi **berapa banyak sistem/codebase yang terdampak** (contoh: 2 — backend/frontend sistem Kantin baru, plus penambahan tipis di backend/frontend HRIS existing). Setiap sistem yang terdampak dapat kelompok task terpisah; kalau sistem itu repo terpisah, tiketnya diberi field `repo:` (lihat `feature-flow` bagian Multi-Repo).

## Ukuran Tiket — Potongan Perilaku, Bukan Per Layer

Satu tiket = **satu perilaku yang bisa dites sendiri dari ujung ke ujung di satu repo**. Migration, entity, DTO, service, endpoint, validasi, test, dan dokumentasi Swagger untuk perilaku itu masuk ke **tiket yang sama**. Setiap tiket punya biaya tetap (developer → review → QA), jadi tiket yang terlalu kecil memperlambat, bukan mempercepat.

- **Jangan pecah per layer atau per file.** Tidak ada tiket terpisah untuk "buat migration", "buat DTO", "buat controller", "tulis test", "tambah Swagger", atau "seeder" — itu bagian dari tiket fitur yang membutuhkannya.
- **Pecah hanya kalau:** (a) beda repo, (b) potongan itu berguna dan bisa diuji sendiri (misal "buat PO" dan "approve PO"), atau (c) satu tiket akan menyentuh lebih dari ±10 file atau ±400 baris.
- **Target jumlah:** revisi atau perubahan pada fitur yang sudah ada: **1–3 tiket**. Fitur baru: umumnya **2–6 tiket per repo**. Kalau hasilnya lebih dari 8 tiket untuk satu fitur, gabungkan ulang dulu; kalau memang perlu lebih, tulis alasannya.
- Fondasi yang dipakai beberapa tiket sekaligus (misal tabel master yang dipakai tiga fitur) boleh jadi satu tiket sendiri.

## Langkah 2: Ekstrak Task dari Tiap Section PRD

| Section PRD | Jadi task tipe |
|---|---|
| Database Schema | Migration ikut tiket fitur yang memakai tabel itu. Tiket tersendiri hanya kalau tabelnya fondasi untuk beberapa tiket |
| Core Features | Satu tiket per fitur per repo (backend: logic + endpoint + test; frontend: UI + state + test). Sub-bullet fitur tidak dipecah jadi tiket sendiri kecuali bisa berdiri dan diuji sendiri |
| Architecture — proxy/integrasi | Task terpisah khusus integrasi (lihat Langkah 3) |
| API Design | Kalau endpoint sudah dirinci di PRD, jadikan checklist implementasi endpoint per grup, bukan diulang task per endpoint tunggal kecuali endpoint-nya kompleks |
| User Flow (percabangan kondisional) | Masuk sebagai AC di tiket fitur terkait. Tiket tersendiri hanya untuk proses yang berjalan terpisah (job scheduler, cut-off otomatis) — sering luput kalau cuma dipecah dari Core Features saja |
| Design & Technical Constraints | Task setup awal (project scaffolding, CI/CD, environment config) — hanya untuk project baru, skip untuk project existing |

## Langkah 3: Task Integrasi — Presisi, Jangan Generik

Ini bagian yang paling sering salah kalau dikerjakan asal: **task integrasi ke sistem existing harus dibatasi seketat yang ditulis di PRD**, tidak melebar jadi duplikasi business logic.

Prinsip (berlaku kalau PRD menyebut pola "proxy tipis" atau serupa):
- Kalau PRD bilang sisi existing hanya menambah **proxy layer tipis** (auth + forward, tanpa business logic), task-nya juga cuma itu — jangan bikin task yang mengimplementasikan ulang logic yang sudah ada di sistem baru
- Sebutkan **role/middleware yang sudah ada dan dipakai ulang** (contoh: "role `employee`/`hr`/`administrator` sudah ada di `models.UserRole`, tidak perlu role baru") sebagai catatan di task, supaya developer tidak menciptakan struktur baru yang tidak perlu
- Kalau ada **mekanisme yang belum ada dan perlu dibuat baru** (contoh dari PRD: service-to-service auth belum ada di sistem existing), ini jadi task tersendiri yang ditandai jelas sebagai **penambahan baru ke sistem existing**, bukan bagian dari sistem baru
- Task sinkronisasi data (kalau ada, misal cache identitas lintas sistem) dipisah dari task CRUD biasa, karena biasanya butuh pertimbangan khusus (jadwal sync, apa yang boleh/tidak boleh ditimpa — cek kolom "Keterangan" di Database Schema PRD untuk aturan semacam ini)

## Langkah 4: Struktur Output

Kelompokkan task per **fase** (urutan pengerjaan logis, bukan cuma per modul), lalu per **sistem/layer** di dalam fase itu. Format:

```markdown
## Fase 1: [Nama Fase — misal "Database & Core Backend"]

### Backend — [Nama Sistem, misal "Kantin (baru)"]
- [ ] **[TASK-ID]** [Judul task singkat, actionable]
  - **Deskripsi:** [apa yang dikerjakan, 1-2 kalimat]
  - **Acuan PRD:** [section/bagian PRD terkait, misal "Database Schema — tabel orders"]
  - **Trace:** [hanya kalau ada dokumen `erp-brd-traceability` — `US-INV-001 / TECH-003 / AC-002` yang dipenuhi task ini]
  - **File/lokasi:** [path konkret kalau project existing, atau struktur folder yang berlaku dari `coding-standards`]
  - **Acceptance Criteria:**
    - [ ] [kriteria terverifikasi 1]
    - [ ] [kriteria terverifikasi 2]
  - **Cara Verifikasi:** [langkah/command konkret untuk membuktikan task ini benar-benar selesai — bukan cuma "sudah dikerjakan". Contoh: "jalankan `go test ./internal/usecase/order/...`, semua lulus" atau "curl endpoint dengan payload X, cek response match skema Y" atau "buka halaman Z, submit form, cek data masuk ke tabel yang benar". Task tanpa cara verifikasi yang jelas biasanya berarti task-nya masih terlalu kabur — pecah lagi]
  - **Dependency:** [task lain yang harus selesai duluan, kalau ada — "Tidak ada" kalau tidak ada]
  - **Estimasi:** [S/M/L atau story point, opsional — hanya isi kalau user minta]

### Backend — [Nama Sistem Existing, misal "HRIS (existing, penambahan)"]
- [ ] **[TASK-ID]** [...]
```

**Aturan penomoran Task-ID:** prefix per sistem/modul supaya gampang dilacak, misal `KTN-BE-001` (Kantin Backend), `KTN-FE-001` (Kantin Frontend), `HR-INT-001` (integrasi di HRIS) — konsisten dan pendek.

**Traceability ke `erp-brd-traceability` (kalau dokumennya ada):**
- Setiap TECH-xxx tercakup **minimal satu** task; beberapa TECH kecil untuk perilaku yang sama boleh digabung dalam satu task (kolom Trace berisi semuanya). TECH yang terlalu besar boleh dipecah jadi beberapa task, tapi semuanya merujuk TECH yang sama di kolom **Trace** — jangan buat ulang task dari PRD untuk hal yang sudah tercakup TECH.
- Acceptance Criteria task diambil dari AC-xxx yang dirujuk TECH tersebut (tulis ID-nya, misal `AC-002: qty > outstanding ditolak`), bukan ditulis ulang dengan kata-kata baru.
- Task tambahan yang tidak berasal dari TECH mana pun (setup, CI/CD, integrasi existing) tetap boleh, tapi kolom Trace diisi `—` dan alasannya di Deskripsi.
- Setelah task list jadi, sertakan tabel ringkas di akhir supaya rantai BR→…→TECH→Task tidak putus:

```markdown
| TECH | Task-ID | AC yang dipenuhi | Test Case |
|---|---|---|---|
| US-INV-001 / TECH-003 | WMS-BE-004 | AC-002 | TC-INV-002 |
```

Cek ulang sebelum selesai: setiap TECH punya ≥1 task, dan setiap AC muncul di minimal satu task. Kalau ada yang bolong, sebutkan ke user.

## Langkah 5: Urutan Fase yang Wajar

Default urutan (sesuaikan kalau PRD punya kebutuhan berbeda):
1. **Database & migration** — fondasi, semua task lain bergantung ke sini
2. **Backend core** — business logic utama sebelum endpoint
3. **API endpoints** — setelah logic ada
4. **Integrasi ke sistem existing** (proxy, sync endpoint) — setelah API utama stabil, supaya tidak integrasi ke API yang masih berubah-ubah
5. **Frontend** — bisa paralel dengan integrasi kalau tim beda orang, tapi urutkan setelah API dasar ada
6. **Fitur pendukung** (notifikasi, analitik, export laporan) — biasanya bisa belakangan, tidak blocking fitur inti
7. **QA/testing & dokumentasi** — termasuk kalau perlu `api-doc-standard` atau `user-guide` sebagai task terpisah di fase ini

Tandai task mana yang **bisa dikerjakan paralel** vs yang **strictly sequential** lewat kolom Dependency, supaya kalau dikerjakan tim/beberapa orang jelas mana yang boleh mulai bersamaan.

## Langkah 6: Setelah Task List Jadi

- Tawarkan push ke tracker kalau relevan (misal user pakai Notion untuk project management) — cek dulu apakah ada konektor yang tersedia sebelum menyarankan, jangan asumsikan tool tertentu tanpa konfirmasi
- Task list disimpan sebagai file Markdown lewat tool pembuat file yang tersedia di environment ini, supaya bisa disimpan/di-share, kecuali user memang mau langsung didorong ke tool lain

## Prinsip

1. **Task harus actionable dalam satu duduk kerja, tapi tidak lebih kecil dari satu perilaku yang bisa dites.** Ukurannya mengikuti bagian Ukuran Tiket di atas.
2. **Setiap task bisa ditelusuri balik ke PRD.** Kolom "Acuan PRD" bukan formalitas — kalau ada task yang tidak bisa dikaitkan ke bagian PRD manapun, pertanyakan apakah task itu memang perlu atau scope creep.
3. **Jangan buat task duplikat logic antar sistem.** Kalau sistem A (baru) dan sistem B (existing) sama-sama tersentuh oleh satu fitur, business logic hanya ada di satu tempat (sesuai keputusan Architecture di PRD) — sistem satunya cuma task integrasi/proxy.
4. **Realistis dengan apa yang sudah ada.** Jangan sarankan "buat ulang struktur folder" atau "refactor besar" kalau PRD tidak memintanya — task integrasi menyesuaikan diri ke existing project, bukan sebaliknya, kecuali user secara eksplisit minta refactor.
5. **"Selesai" dibuktikan lewat Cara Verifikasi, bukan diklaim.** Task dicentang selesai setelah langkah di kolom "Cara Verifikasi" benar-benar dijalankan dan hasilnya sesuai — bukan karena kodenya "kelihatannya sudah benar".
6. **Task refactor butuh rencana sebelum jadi task-list biasa.** Kalau di antara task ada yang tipenya refactor besar (bukan sekadar tambah fitur baru), jangan langsung dipecah seperti task fitur biasa — task pertamanya adalah "susun rencana refactor" (lihat `coding-standards` bagian 1, prinsip 6) sebagai deliverable tersendiri, baru task-task eksekusinya mengikuti rencana itu setelah direview.

## Referensi Skill Terkait
- `prd-writer` — sumber PRD yang jadi acuan breakdown
- `erp-brd-traceability` — kalau ada, sumber US/AC/TECH yang wajib dirujuk di kolom Trace
- `coding-standards` — dipakai untuk struktur folder/konvensi task backend/frontend kalau project baru (tidak ada existing pattern untuk diikuti)
- `standup-update` — setelah task dikerjakan, progress-nya bisa dirangkum pakai skill ini
