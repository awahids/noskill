# prd-writer

Menyusun Product Requirements Document (PRD) lengkap dengan struktur baku — Overview, Requirements, Core Features, User Flow, Architecture, Database Schema, API Design, Design & Technical Constraints — wajib menyertakan diagram (flowchart/sequence diagram/ERD) dalam format Mermaid.

## Isinya

- Alur wajib: deskripsi singkat → minimal 5 pertanyaan klarifikasi → baru generate PRD (bukan langsung drafting)
- Mode Reverse-PRD: menyusun PRD dari kode/project yang sudah ada tapi belum terdokumentasi
- Contoh acuan lengkap (PRD SmartCatering HR) sebagai referensi pola penulisan dan gaya bahasa

## Kapan dipakai

Setiap kali diminta "buatkan PRD", "susun product requirements", "dokumen requirement", atau scoping sistem baru.

## Terkait

- `coding-standards` — acuan konvensi teknis untuk bagian Architecture/Database/API di PRD
- `task-breakdown` — memecah PRD hasil skill ini jadi task development
- `mockup-prototype` — menerjemahkan PRD jadi wireframe/mockup
- `erp-domain-design` / `erp-brd-traceability` — untuk fitur ERP/WMS, jalankan desain domain dulu dan lanjutkan PRD ke rantai requirement formal (BR→PROC→US→AC)
