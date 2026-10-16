---
name: rapikan
description: Shortcut — rapikan tiket yang sudah dibuat supaya sesuai aturan tiket terbaru (gabung tiket per layer, lengkapi Kontrak API, integrates_with, complexity, AC negatif, File/Lokasi nyata), atau review ulang kode tiket yang sudah DONE. Pakai sebagai /noskill:rapikan [ID tiket] atau /noskill:rapikan review <ID>.
disable-model-invocation: true
---

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.

Argumen: $ARGUMENTS

- Kosong atau berisi ID tiket → **Rapikan backlog** (semua tiket yang memenuhi syarat, atau hanya ID itu).
- Diawali `review` lalu ID tiket → **Review ulang tiket DONE**.

Kamu bertindak sebagai orkestrator (`feature-flow`), jadi boleh mengubah file tiket — tapi hanya setelah user menyetujui usulan.

## Rapikan backlog

Yang diproses hanya tiket berstatus `TODO` dan `HOLD`. Tiket `IN_PROGRESS`, `REVIEW`, `QA`, `BUG`, dan `DONE` tidak diubah; kalau ada masalah di sana, cukup disebut di laporan.

1. Ambil gambaran board sekaligus: `grep -H "^status:\|^title:\|^depends_on:\|^integrates_with:\|^complexity:\|^repo:" <docs>/tickets/*.md`. Baca penuh hanya tiket yang diproses, ditambah PRD/BRD dan kode yang perlu untuk mengecek.
2. Cek setiap tiket terhadap bagian Aturan Tiket di `task-breakdown` dan format `ticket-workflow`:
   - **Per layer atau per file** (migration, DTO, service, controller, test, Swagger sendiri-sendiri) → gabung ke tiket endpoint/fitur yang membutuhkannya.
   - **Terlalu besar** (beberapa endpoint yang bukan CRUD kecil, atau beberapa repo dalam satu tiket) → pecah.
   - **Tiket BE untuk endpoint tanpa `## Kontrak API`** → lengkapi dari PRD/BRD atau kode yang ada. Yang tidak tertulis di sumber mana pun jadi pertanyaan, bukan dikarang.
   - **Tiket FE yang memakai endpoint tiket BE lewat `depends_on`** → ganti jadi `integrates_with`.
   - **`complexity` kosong** → isi sesuai kriteria `ticket-workflow` (ragu → `complex`).
   - **File/Lokasi generik atau path yang tidak ada** → ganti dengan path nyata (cek dengan glob/grep).
   - **AC tanpa sisi negatif** → tambahkan dari aturan atau pengecualian di PRD/BRD; kalau tidak ada dasarnya, jadikan pertanyaan.
   - **Duplikat, atau sudah tercakup tiket DONE** → usulkan dihapus.
3. **Tampilkan usulan, jangan ubah file dulu:**
   - Tabel: ID lama → aksi (gabung / pecah / lengkapi / hapus / tetap) → ID hasil → alasan singkat
   - Board sesudah dirapikan, dan jumlah tiket sebelum → sesudah
   - Pertanyaan terbuka
   Lalu minta persetujuan user.
4. **Setelah disetujui:**
   - Gabung: tiket hasil memakai ID tiket pertama dalam kelompok itu; AC, File/Lokasi, `trace`, `depends_on` digabung tanpa duplikat. File tiket lain dihapus. Riwayat tiket hasil ditambah `- <YYYY-MM-DD HH:MM> <STATUS> — dirapikan: gabungan dari <ID>, <ID>`.
   - Pecah: tiket baru memakai nomor lanjutan terakhir, Riwayat `- <YYYY-MM-DD HH:MM> TODO — dirapikan: dipecah dari <ID>`.
   - Lengkapi: ubah bagian yang kurang saja, Riwayat `- <YYYY-MM-DD HH:MM> <STATUS> — dirapikan: <apa yang dilengkapi>`.
   - Perbarui `depends_on` dan `integrates_with` di semua tiket (termasuk yang tidak diproses) yang merujuk ID yang hilang.
   - Kalau tracker aktif dan tiket punya `tracker_ref`, tutup issue/baris tiket yang dihapus dengan catatan "digabung ke <ID>", dan perbarui yang berubah.
   - Kalau repo git, commit file tiket: `chore(tickets): rapikan backlog`.
5. Laporan akhir: jumlah tiket sebelum → sesudah, board terbaru, dan tiket berikutnya yang akan diambil.

## Review ulang tiket DONE

1. Pastikan tiket berstatus `DONE`. Kalau belum DONE, katakan bahwa tiket itu masih di alur biasa dan berhenti.
2. Cari commit tiket: `git log --grep "^<ID>:" --format="%h %s"` (multi-repo: di repo yang tertulis di field `repo`). Kalau tidak ketemu, tanya user commit atau range-nya.
3. Panggil agent `ticket-reviewer` dengan path tiket, direktori kerja repo tiket, path laporan `<docs>/reports/<ID>/rereview-<n>.md`, dan instruksi: "Nilai perubahan di commit <hash> (`git show --stat <hash>` dan `git show <hash>`), bukan working tree. Ini review ulang tiket yang sudah DONE."
4. Hasil:
   - `APPROVED` → tambah Riwayat `- <YYYY-MM-DD HH:MM> DONE — review ulang: APPROVED`.
   - `CHANGES_REQUESTED` → tiket asal tetap DONE dengan Riwayat `- <YYYY-MM-DD HH:MM> DONE — review ulang: ada temuan, lihat <BUG-ID>`. Buat tiket `BUG-NNN` baru (`type: bug`, `status: BUG`, `related: [<ID>]`, `complexity` sesuai temuan) dengan temuan reviewer sebagai AC dan File/Lokasi dari commit itu.
   - `BLOCKED` → tampilkan pertanyaan reviewer ke user.
5. Tampilkan hasilnya. Tiket BUG baru dikerjakan lewat `/noskill:lanjut` atau `feature-flow`.
