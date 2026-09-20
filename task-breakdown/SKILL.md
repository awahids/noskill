---
name: task-breakdown
description: Memecah PRD menjadi daftar task development yang actionable, dikelompokkan per fase/modul/layer, dengan acceptance criteria dan dependency. KHUSUS untuk project yang terintegrasi ke sistem existing atau menambah ke codebase yang sudah ada — task disesuaikan dengan struktur, konvensi, dan file/folder yang SUDAH ADA di project tersebut (bukan scaffolding generik dari nol), termasuk task integrasi yang presisi sesuai bagian Architecture/Integrasi di PRD. Gunakan skill ini setelah PRD selesai (dari `prd-writer` atau PRD yang di-upload user) dan user minta "buatkan task", "pecah jadi task", "breakdown PRD ini", "buat backlog dari PRD", atau "task list untuk development".
---

# PRD to Task Breakdown

Mengubah PRD menjadi task list yang siap masuk ke tracker (Notion/Jira/Trello/GitHub Issues) atau langsung dikerjakan. Beda dari `prd-writer` (dokumen requirement) — skill ini fokus ke **eksekusi**: apa yang harus dikerjakan, dalam urutan apa, dan siapa/sistem mana yang terdampak.

## Langkah 1: Pahami Konteks Project

**Sebelum membuat task, tentukan dulu:**

1. **Project baru murni (greenfield)** atau **integrasi/penambahan ke project existing**? Cek bagian Architecture di PRD — kalau ada penyebutan sistem lain yang sudah berjalan (repo existing, stack yang harus disamakan, endpoint yang sudah ada), ini kasus integrasi.
2. Kalau **integrasi ke existing project**, task **wajib mengikuti struktur folder, pola kode, dan konvensi yang sudah disebutkan PRD-nya sebagai existing** — bukan membuat task "setup project baru dari nol". Kutip path/file konkret yang disebut PRD (contoh dari PRD SmartCatering HR: `server/internal/delivery/handlers/catering_proxy.handler.go`, pola `stores/attendance.js`) sebagai referensi langsung di task, bukan folder generik seperti `src/handlers/`.
3. Kalau PRD tidak menyebutkan detail struktur existing secara spesifik tapi menyebut "terintegrasi ke sistem X", **tanyakan ke user** apakah ada akses ke codebase existing tersebut (path lokal, repo) supaya task-nya presisi — jangan menebak struktur folder yang tidak disebutkan.
4. Identifikasi **berapa banyak sistem/codebase yang terdampak** (di contoh SmartCatering: 2 — backend/frontend SmartCatering baru, plus penambahan tipis di backend/frontend Absensi existing). Setiap sistem yang terdampak dapat kelompok task terpisah.

## Langkah 2: Ekstrak Task dari Tiap Section PRD

| Section PRD | Jadi task tipe |
|---|---|
| Database Schema | Migration per tabel (atau per grup tabel terkait), seeder kalau perlu data awal |
| Core Features | Task backend (business logic + endpoint) dan frontend (UI + integrasi state) per fitur, biasanya bisa dipecah lagi per sub-bullet fitur |
| Architecture — proxy/integrasi | Task terpisah khusus integrasi (lihat Langkah 3) |
| API Design | Kalau endpoint sudah dirinci di PRD, jadikan checklist implementasi endpoint per grup, bukan diulang task per endpoint tunggal kecuali endpoint-nya kompleks |
| User Flow (percabangan kondisional) | Task tersendiri untuk logic percabangan/otomatisasi (misal job scheduler, cut-off logic) — sering luput kalau cuma dipecah dari Core Features saja |
| Design & Technical Constraints | Task setup awal (project scaffolding, CI/CD, environment config) — hanya untuk project baru, skip untuk project existing |

## Langkah 3: Task Integrasi — Presisi, Jangan Generik

Ini bagian yang paling sering salah kalau dikerjakan asal: **task integrasi ke sistem existing harus dibatasi seketat yang ditulis di PRD**, tidak melebar jadi duplikasi business logic.

Prinsip (selaras dengan pola "proxy tipis" di PRD SmartCatering — kalau PRD menyebut pola serupa):
- Kalau PRD bilang sisi existing hanya menambah **proxy layer tipis** (auth + forward, tanpa business logic), task-nya juga cuma itu — jangan bikin task yang mengimplementasikan ulang logic yang sudah ada di sistem baru
- Sebutkan **role/middleware yang sudah ada dan dipakai ulang** (contoh: "role `employee`/`hr`/`administrator` sudah ada di `models.UserRole`, tidak perlu role baru") sebagai catatan di task, supaya developer tidak menciptakan struktur baru yang tidak perlu
- Kalau ada **mekanisme yang belum ada dan perlu dibuat baru** (contoh dari PRD: service-to-service auth belum ada di sistem existing), ini jadi task tersendiri yang ditandai jelas sebagai **penambahan baru ke sistem existing**, bukan bagian dari sistem baru
- Task sinkronisasi data (kalau ada, misal cache identitas lintas sistem) dipisah dari task CRUD biasa, karena biasanya butuh pertimbangan khusus (jadwal sync, apa yang boleh/tidak boleh ditimpa — cek kolom "Keterangan" di Database Schema PRD untuk aturan semacam ini)

## Langkah 4: Struktur Output

Kelompokkan task per **fase** (urutan pengerjaan logis, bukan cuma per modul), lalu per **sistem/layer** di dalam fase itu. Format:

```markdown
## Fase 1: [Nama Fase — misal "Database & Core Backend"]

### Backend — [Nama Sistem, misal "SmartCatering (baru)"]
- [ ] **[TASK-ID]** [Judul task singkat, actionable]
  - **Deskripsi:** [apa yang dikerjakan, 1-2 kalimat]
  - **Acuan PRD:** [section/bagian PRD terkait, misal "Database Schema — tabel orders"]
  - **File/lokasi:** [path konkret kalau project existing, atau struktur folder yang berlaku dari `coding-standards`]
  - **Acceptance Criteria:**
    - [ ] [kriteria terverifikasi 1]
    - [ ] [kriteria terverifikasi 2]
  - **Cara Verifikasi:** [langkah/command konkret untuk membuktikan task ini benar-benar selesai — bukan cuma "sudah dikerjakan". Contoh: "jalankan `go test ./internal/usecase/order/...`, semua lulus" atau "curl endpoint dengan payload X, cek response match skema Y" atau "buka halaman Z, submit form, cek data masuk ke tabel yang benar". Task tanpa cara verifikasi yang jelas biasanya berarti task-nya masih terlalu kabur — pecah lagi]
  - **Dependency:** [task lain yang harus selesai duluan, kalau ada — "Tidak ada" kalau tidak ada]
  - **Estimasi:** [S/M/L atau story point, opsional — hanya isi kalau user minta]

### Backend — [Nama Sistem Existing, misal "Absensi (existing, penambahan)"]
- [ ] **[TASK-ID]** [...]
```

**Aturan penomoran Task-ID:** prefix per sistem/modul supaya gampang dilacak, misal `SC-BE-001` (SmartCatering Backend), `SC-FE-001` (SmartCatering Frontend), `ABS-INT-001` (Absensi Integration) — konsisten dan pendek.

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

1. **Task harus actionable dalam satu duduk kerja.** Kalau task terlalu besar untuk dikerjakan dan diverifikasi dalam sekali jalan, pecah lagi.
2. **Setiap task bisa ditelusuri balik ke PRD.** Kolom "Acuan PRD" bukan formalitas — kalau ada task yang tidak bisa dikaitkan ke bagian PRD manapun, pertanyakan apakah task itu memang perlu atau scope creep.
3. **Jangan buat task duplikat logic antar sistem.** Kalau sistem A (baru) dan sistem B (existing) sama-sama tersentuh oleh satu fitur, business logic hanya ada di satu tempat (sesuai keputusan Architecture di PRD) — sistem satunya cuma task integrasi/proxy.
4. **Realistis dengan apa yang sudah ada.** Jangan sarankan "buat ulang struktur folder" atau "refactor besar" kalau PRD tidak memintanya — task integrasi menyesuaikan diri ke existing project, bukan sebaliknya, kecuali user secara eksplisit minta refactor.
5. **"Selesai" dibuktikan lewat Cara Verifikasi, bukan diklaim.** Task dicentang selesai setelah langkah di kolom "Cara Verifikasi" benar-benar dijalankan dan hasilnya sesuai — bukan karena kodenya "kelihatannya sudah benar".
6. **Task refactor butuh rencana sebelum jadi task-list biasa.** Kalau di antara task ada yang tipenya refactor besar (bukan sekadar tambah fitur baru), jangan langsung dipecah seperti task fitur biasa — task pertamanya adalah "susun rencana refactor" (lihat `coding-standards` bagian 1, prinsip 6) sebagai deliverable tersendiri, baru task-task eksekusinya mengikuti rencana itu setelah direview.

## Referensi Skill Terkait
- `prd-writer` — sumber PRD yang jadi acuan breakdown
- `coding-standards` — dipakai untuk struktur folder/konvensi task backend/frontend kalau project baru (tidak ada existing pattern untuk diikuti)
- `standup-update` — setelah task dikerjakan, progress-nya bisa dirangkum pakai skill ini
