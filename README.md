# Portal Berkas Klien

Website statis (HTML) + Supabase untuk database dan penyimpanan file.

## Pasang (sekitar 15 menit)
1. Buat akun di supabase.com, lalu **New project**.
2. Buka **SQL Editor**, tempel isi `schema.sql`, klik **Run**.
3. **Authentication > Users > Add user**: buat satu akun (email + kata sandi) untuk Anda. Di **Authentication > Sign In / Providers**, matikan pendaftaran publik (Allow new users to sign up).
4. **Project Settings > API**: salin *Project URL* dan *anon public key* ke `config.js`. Isi juga nomor WA Anda.
5. Buat repo di GitHub, unggah semua file ini.
6. Tayangkan: **Settings > Pages** di repo (branch main), atau sambungkan repo ke Vercel/Netlify. Domain sendiri bisa dipasang belakangan.

## Cara pakai
- Buka `alamat-anda/admin.html`, masuk, lalu **Order baru**.
- Salin link klien (atau kirim lewat WA dari tombolnya). Klien membuka link, mengunggah, dan centang muncul otomatis.
- File tersimpan di Supabase **Storage > berkas** (privat). Unduh dari halaman admin.

## Catatan keamanan
- Anon key memang publik; yang menjaga data adalah aturan (RLS) di `schema.sql`.
- Klien hanya bisa membuka order miliknya lewat token acak 24 karakter. Jangan bagikan link ke orang lain.
- Jangan simpan berkas klien di repo GitHub.
