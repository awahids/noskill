---
type: llm
focus: last_message
---

PASS jika rapat benar-benar terjadi sebelum tiket ditulis: notulen memuat peserta (minimal task-planner, ticket-reviewer, dan satu developer), keputusan, risiko, dan asumsi (misalnya aturan pembulatan 0,5 dan memakai helper clamp yang sudah ada di lib/math.js), dan jawaban akhir menampilkan board tiket lalu meminta persetujuan tanpa menjalankan implementasi.
FAIL jika tiket ditulis tanpa rapat, notulen tidak memuat peserta atau keputusan, atau implementasi dijalankan.
