# debug-assistant

Panduan debugging terstruktur untuk masalah backend/API/integrasi (NestJS, Laravel, Golang/Gin, WMS API, integrasi n8n/Power Automate, dll) — reproduce, isolasi, diagnosa akar masalah, dan verifikasi fix, bukan tebak-tebakan.

## Isinya

- Alur debugging: Reproduce → Isolasi → Diagnosa → Fix & Verifikasi → Cegah Berulang
- Teknik diagnosa spesifik: root-cause tracing, defense-in-depth, condition-based waiting (untuk race condition)
- Prinsip **evidence over claims** — tidak boleh klaim "sudah fix" tanpa bukti hasil reproduce/test ulang
- Kasus khusus integrasi API eksternal (WMS API, n8n, Power Automate, Microsoft Graph)

## Kapan dipakai

Setiap kali user melaporkan error, bug, stack trace, "kok error", "gak jalan", "works in staging tapi gak di production", API call gagal, atau minta bantuan troubleshoot masalah teknis apa pun.
