# api-doc-standard

Standar dokumentasi API (Swagger/OpenAPI) untuk NestJS, Laravel, dan Golang/Gin (swaggo) — konvensi penulisan decorator/annotation, struktur response schema, dan penamaan tag/endpoint agar dokumentasi konsisten antar service.

## Isinya

- Prinsip dokumentasi API (wajib dibuat bersamaan dengan kode, contoh request/response realistis)
- Struktur wajib per endpoint untuk NestJS (`@nestjs/swagger`), Laravel (anotasi/`l5-swagger`/`scramble`), dan Golang/Gin (`swaggo/swag`)
- Standar response schema
- Setup Swagger/OpenAPI untuk versioning
- Checklist breaking change sebelum naik versi
- Checklist sebelum merge

## Kapan dipakai

Setiap kali membuat endpoint baru, menulis dokumentasi API, menambahkan Swagger decorator/anotasi/komentar swaggo, atau saat diminta "dokumentasi endpoint", "swagger", "openapi", "api spec".

## Terkait

- `coding-standards` — path versioning API (`/api/v{n}`) mengikuti standar di skill ini bagian 6.1
