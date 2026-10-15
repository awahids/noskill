---
name: lanjut
description: Shortcut — lanjutkan alur tiket yang tertunda dari sesi sebelumnya (feature-flow Tahap 5) berdasarkan status file tiket. Pakai sebagai /noskill:lanjut [catatan atau jawaban untuk tiket HOLD].
disable-model-invocation: true
---

Folder dokumen noskill: `${user_config.docs_dir}` — selanjutnya ditulis `<docs>`. Kalau nilai itu masih tertulis apa adanya (tidak tersubstitusi), pakai `docs/noskill`.
Lanjutkan skill `feature-flow` dari kondisi terakhir yang tersimpan di file, bukan dari awal:

1. Baca board (`grep -H "^status:" <docs>/tickets/*.md`) dan `<docs>/project-profile.md` kalau ada.
2. Pastikan berada di branch kerja fitur ini (`git branch --show-current`). Kalau ada folder `.worktrees/`, cocokkan dengan tiket yang masih aktif (`git worktree list`).
3. Tiket yang berhenti di tengah dilanjutkan dari tahapnya:
   - `IN_PROGRESS` → panggil developer lagi
   - `REVIEW` → panggil reviewer
   - `QA` → panggil QA
   - `BUG` → panggil developer dengan bug report terakhir
4. Kalau ada catatan dari user di bawah ini, anggap itu jawaban untuk tiket HOLD: catat di Riwayat-nya, lalu kembalikan tiket ke status sebelum HOLD.

$ARGUMENTS

5. Lanjutkan loop Tahap 5 seperti biasa sampai semua DONE atau ada yang perlu keputusan user.
