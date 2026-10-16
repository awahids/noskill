---
name: board
description: Shortcut — tampilkan board tiket per status, pertanyaan yang menunggu jawaban di tiket HOLD, dan durasi tiap tahap (developer, review, QA) per tiket. Pakai sebagai /noskill:board.
disable-model-invocation: true
---

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.
Tampilkan board dari `<docs>/tickets/` tanpa mengubah file apa pun:

1. Ambil status semua tiket sekaligus: `grep -H "^status:\|^title:\|^rounds:\|^repo:" <docs>/tickets/*.md`. Jangan membaca file tiket satu per satu kecuali untuk tiket HOLD.
2. Tampilkan satu tabel berurutan TODO · IN_PROGRESS · REVIEW · QA · BUG · HOLD · DONE, dengan kolom ID, judul, dan rounds (plus kolom repo kalau ada tiket yang punya field `repo`).
3. Untuk tiket HOLD, baca baris terakhir `## Riwayat`-nya dan tampilkan pertanyaan yang menunggu jawaban user.
4. **Durasi per tahap.** Hitung dengan command, jangan di kepala:
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
   Hasilnya menit per tiket untuk tahap developer (termasuk revisi/BUG), review, dan QA. Waktu tunggu di TODO dan HOLD tidak dihitung; waktu tiket FE menunggu tiket BE-nya ikut terhitung di QA. Tiket lama yang Riwayat-nya tanpa jam tidak muncul. Kalau `python3` tidak ada, lewati langkah ini dan sebutkan.
   Tampilkan tabel durasi untuk tiket DONE (dev · review · QA · total), rata-rata per tahap, dan tahap yang paling lama — itu kandidat optimasi berikutnya.
5. Tutup dengan satu baris: jumlah per status dan tiket berikutnya yang akan diambil sesuai urutan di skill `ticket-workflow`.

Kalau `<docs>/tickets/` tidak ada, katakan belum ada tiket dan sarankan `/noskill:fix` atau `/noskill:feature-flow`.
