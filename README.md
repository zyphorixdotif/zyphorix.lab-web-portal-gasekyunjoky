# Portal Berkas Klien

Website tempat klien mengirim berkas dan isian teks yang Anda minta, tanpa lewat WhatsApp. Setiap klien punya link sendiri. Setiap item yang sudah dikirim otomatis tercentang, dan Anda bisa melihat semuanya di halaman admin.

Dokumen ini berisi semua yang sudah dibahas: cara pasang dari nol, cara pakai, fitur isian teks, batasan, penjelasan istilah (Supabase, GitHub, Vercel), keamanan, dan cara mengatasi masalah.

---

## Daftar isi

1. Gambaran umum
2. Isi folder
3. Cara kerja
4. Pemasangan langkah demi langkah
5. Cara memakai sehari-hari
6. Fitur isian teks (`teks:`)
6b. Fitur banyak file per item (`banyak:`)
7. Jenis file dan batasan
8. Urutan menjalankan SQL dan berkas mana yang perlu diunggah
9. Memahami istilah: akun, organization, project, repositori
10. GitHub: publik atau privat, dan soal Vercel
11. Keamanan
12. Jika ada masalah
13. Fitur yang belum ada

---

## 1. Gambaran umum

Website ini terdiri dari dua halaman dan satu backend:

- **Halaman klien** (`index.html`): klien membuka link uniknya, melihat daftar yang diminta, lalu mengunggah file atau mengetik jawaban.
- **Halaman admin** (`admin.html`): khusus Anda, pakai login. Untuk membuat order, mengirim link, melihat progres, membaca jawaban, dan mengunduh berkas.
- **Backend** memakai **Supabase**: menyimpan data order, jawaban teks, dan file klien.
- Kode website disimpan di **GitHub** dan ditayangkan lewat **GitHub Pages**.

Alur singkat:

1. Klien membayar.
2. Anda membuat order di halaman admin, memilih jenis layanan, dan sistem membuat link unik berisi token acak.
3. Link dikirim ke klien (bisa langsung lewat tombol WA).
4. Klien membuka link, mengunggah berkas dan mengisi teks yang diminta. Centang muncul otomatis.
5. Anda membuka halaman admin untuk melihat progres dan mengunduh berkas.

---

## 2. Isi folder

| Berkas | Fungsi | Perlu diunggah ke GitHub? |
|---|---|---|
| `index.html` | Halaman klien | Ya |
| `admin.html` | Halaman admin | Ya |
| `config.js` | Alamat dan kunci Supabase, nomor WA | Ya (sudah diisi) |
| `style.css` | Tampilan | Ya |
| `schema.sql` | Membuat tabel, penyimpanan, dan aturan keamanan di Supabase | Tidak wajib, tapi disarankan sebagai cadangan |
| `migration.sql` | Menambah fitur isian teks | Tidak wajib, tapi disarankan sebagai cadangan |
| `migration-banyak.sql` | Menambah fitur banyak file per item | Tidak wajib, tapi disarankan sebagai cadangan |
| `README.md` | Panduan ini | Disarankan |

Website hanya butuh `index.html`, `admin.html`, `config.js`, dan `style.css` untuk berjalan. Berkas SQL hanya dibaca Supabase saat Anda menjalankannya di SQL Editor dan tidak dipakai lagi oleh website sesudahnya.

---

## 3. Cara kerja

- Setiap order punya **token** acak 24 karakter. Link klien bentuknya `alamat-anda/index.html?t=TOKEN`.
- Klien tidak perlu login. Siapa pun yang memegang link bisa membuka order itu, jadi kirim link hanya ke klien yang bersangkutan.
- Link memakai `?t=token`, bukan `/u/token`, karena GitHub Pages tidak mendukung alamat bersarang tanpa konfigurasi tambahan.
- File klien tersimpan di **Supabase Storage** (bucket `berkas`, privat), bukan di GitHub.
- Status order berubah otomatis menjadi **Berkas lengkap** ketika semua item (file maupun teks) sudah terisi. Status lainnya (Dikerjakan, Revisi, Selesai) Anda ubah manual di halaman admin.

---

## 4. Pemasangan langkah demi langkah

Nama menu di Supabase atau GitHub kadang sedikit berbeda dari yang tertulis di sini karena tampilannya sering diperbarui, tapi letaknya hampir sama. Ikuti urutannya dari atas.

### Bagian 1: Siapkan Supabase (database dan tempat file)

1. Buka **supabase.com**, klik **Start your project**, lalu daftar (boleh pakai akun GitHub).
2. Klik **New project**. Isi nama (misalnya `portal-berkas`), buat **Database Password** lalu catat di tempat aman, dan pilih region **Singapore** supaya cepat dari Indonesia. Klik **Create**, lalu tunggu sekitar 2 menit.
3. Di menu kiri, buka **SQL Editor**, lalu klik **New query**.
4. Buka berkas `schema.sql` dengan Notepad, salin semua isinya, tempel ke kotak SQL, lalu klik **Run**. Kalau berhasil, muncul tulisan *Success*. Kalau muncul error merah, jangan lanjut dan cari penyebabnya dulu.
5. Masih di SQL Editor, buat query baru, salin semua isi `migration.sql`, tempel, lalu klik **Run**. Ini menambah fitur isian teks (lihat bagian 6). Jalankan sesudah `schema.sql`, bukan sebelumnya. Lalu jalankan juga `migration-banyak.sql` dengan cara yang sama (fitur banyak file, lihat bagian 6b).
6. Buat akun admin untuk Anda sendiri. Buka **Authentication > Users > Add user > Create new user**, isi email dan kata sandi, lalu **centang "Auto Confirm User"**. Klik **Create user**.
7. Matikan pendaftaran umum supaya orang lain tidak bisa membuat akun. Buka **Authentication > Sign In / Providers** (atau **Settings**), cari **Allow new users to sign up**, lalu matikan dan simpan.
8. Ambil alamat dan kunci akses (lihat penjelasan rinci di bawah langkah ini).

**Cara menemukan Project URL dan kunci:**

- Buka **Project Settings** (ikon roda gigi di menu kiri bawah), lalu pilih **Data API** (di versi lama namanya **API**). Di bagian atas ada kotak **Project URL** atau **API URL**. Itu yang dipakai.
- Bentuknya selalu seperti ini: `https://abcdefghijklmno.supabase.co`. Diawali `https://`, diakhiri `.supabase.co`, tanpa tambahan apa pun setelahnya (tidak ada `/rest/v1` dan tidak ada garis miring di akhir).
- **Bukan** alamat yang tertulis "Source primary database" atau yang berawalan `db.` atau `aws-`. Itu alamat database langsung dan tidak dipakai di website ini.
- Kalau kotak Project URL tidak ketemu, buka **Project Settings > General**, cari **Project ID** (deretan huruf acak sekitar 20 karakter), lalu susun sendiri: `https://` + Project ID + `.supabase.co`.
- Kuncinya ada di halaman yang sama (**Data API** atau **API Keys**). Salin yang bertulisan **anon public** (diawali `eyJ...`). Kalau tidak ada, pakai **Publishable key** (diawali `sb_publishable_`). Kalau website nanti error soal key, cari tab **Legacy API keys** dan pakai anon key di sana.
- **Jangan** menyalin kunci bertulisan **service_role** atau **secret**. Kunci itu bersifat rahasia penuh.

### Bagian 2: Isi pengaturan website

9. Buka `config.js` dengan Notepad dan ganti tiga bagian:
   - `url`: diganti Project URL Anda, alamat lengkap di dalam tanda kutip
   - `key`: diganti kunci anon atau publishable tadi
   - `wa`: diganti nomor WA Anda, dimulai `62` tanpa `+` dan tanpa `0` di depan. Contoh: `6281234567890`
10. Simpan berkasnya. Pastikan tanda kutip `'` tidak terhapus. Hasil akhirnya seperti ini:

```js
window.CFG = {
  url: 'https://abcdefghijklmno.supabase.co',
  key: 'eyJhbGciOi...kunci-panjang...',
  bucket: 'berkas',
  wa: '6281234567890'
};
```

### Bagian 3: Taruh di GitHub dan tayangkan

11. Buka **github.com** dan daftar atau masuk.
12. Klik tombol **+** di kanan atas, pilih **New repository**. Beri nama `portal-berkas`, pilih **Public**, lalu klik **Create repository**. (Publik tidak masalah karena kunci anon memang dirancang terbuka dan file klien tidak disimpan di GitHub. Lihat bagian 10 kalau ingin repositori privat.)
13. Di halaman repo, klik **uploading an existing file**, lalu seret berkas ke sana: `index.html`, `admin.html`, `config.js`, `style.css`, dan sebaiknya juga `schema.sql`, `migration.sql`, `README.md`. Klik **Commit changes**.
14. Buka tab **Settings > Pages**. Pada **Source** pilih **Deploy from a branch**. Pilih branch **main** dan folder **/ (root)**, lalu klik **Save**.
15. Tunggu 1 sampai 3 menit, lalu muat ulang halaman Pages. Alamat website akan muncul, bentuknya `https://username-anda.github.io/portal-berkas/`.

### Bagian 4: Coba sendiri dulu

16. Buka `alamat-anda/admin.html` dan masuk dengan email dan sandi dari langkah 6.
17. Klik **+ Order baru**. Isi nama klien contoh ("Tes Budi"), pilih layanan, dan isi judul. Daftar akan terisi otomatis dari template dan boleh diubah. Klik **Buat order & link**.
18. Klik **Salin link**, lalu tempel di jendela penyamaran (incognito) atau di HP. Seharusnya muncul halaman "Halo, Tes Budi" dengan daftar berkas.
19. Unggah satu file di sana. Centang harus muncul otomatis.
20. Kembali ke halaman admin dan muat ulang. Berkasnya seharusnya sudah tercentang dan tombol **Unduh** berfungsi.

Kalau semua itu jalan, website siap dipakai untuk klien sungguhan.

---

## 5. Cara memakai sehari-hari

1. Setelah klien membayar, buka `admin.html` dan masuk.
2. Klik **+ Order baru**. Isi nama klien, jenis layanan, judul atau topik, dan deadline (boleh kosong).
3. Daftar item terisi otomatis dari template sesuai jenis layanan. Anda boleh menambah, menghapus, atau mengubah barisnya. Satu baris berarti satu item.
4. Klik **Buat order & link**.
5. Di halaman detail order, klik **Kirim lewat WA** (pesan sudah terisi dan Anda tinggal memilih kontak) atau **Salin link** lalu kirim sendiri.
6. Pantau progres di halaman daftar order (misalnya 3/5 item). Buka order untuk melihat detail, membaca jawaban teks, atau mengunduh berkas.
7. Ubah status lewat menu pilihan di pojok kanan atas halaman detail: Menunggu berkas, Berkas lengkap, Dikerjakan, Revisi, Selesai.
8. **Hapus order** menghapus order beserta daftar dan file yang sudah diunggah. Tindakan ini tidak bisa dibatalkan.

Template bawaan: Skripsi, Makalah / Esai, Artikel Ilmiah, KKN.

---

## 6. Fitur isian teks (`teks:`)

Selain unggah file, klien bisa mengetik jawaban. Contohnya untuk pertanyaan seperti "Ceritakan gambaran desa kalian".

### Pemasangan

1. Jalankan `migration.sql` di Supabase SQL Editor satu kali (lihat bagian 8).
2. Ganti `index.html` dan `admin.html` di GitHub dengan versi terbaru: klik berkasnya, klik ikon pensil, hapus semua isinya, tempel isi versi baru, lalu **Commit changes**. Bisa juga lewat **Add file > Upload files** untuk menimpa.
3. Tunggu 1 sampai 2 menit, lalu muat ulang dengan Ctrl + F5.

### Cara menulis daftar di halaman admin

Awali barisnya dengan `teks:` kalau klien harus mengetik jawaban. Baris tanpa awalan itu menjadi unggah file. Contoh:

```
Pedoman penulisan kampus (PDF)
Data kelompok dan lokasi
teks: Ceritakan gambaran desa kalian
teks: Apa program kerja yang sudah direncanakan?
```

Dua baris pertama berupa unggah file. Dua baris terakhir menjadi kotak ketik. Tulisan `teks:` hanya penanda untuk sistem dan tidak muncul di halaman klien.

### Yang dilihat klien

Item teks menampilkan kotak ketik dengan tombol **Simpan jawaban**. Setelah disimpan, centangnya muncul otomatis dan progres bertambah. Klien bisa mengubah jawabannya lagi kapan saja.

### Yang Anda lihat di admin

Jawaban tampil langsung di halaman detail order, di bawah nama item, dan bisa disalin. Item teks tidak punya tombol Unduh.

### Batas panjang teks

- Batasnya **5.000 karakter per jawaban** (sekitar 700 sampai 800 kata). Kotak ketik berhenti menerima huruf setelah batas itu.
- Batas ini ada di dua tempat, jadi kalau mau dinaikkan keduanya harus diubah:
  1. **`index.html`**: cari `maxlength="5000"` dan ganti angkanya, misalnya `maxlength="20000"`.
  2. **Supabase**: di SQL Editor, jalankan ulang fungsi `save_text` dari `migration.sql` dengan angka di baris `length(p_text)>5000` diganti sama dengan angka di atas. Cara termudah: salin bagian `create or replace function save_text ... end $$;` saja, ubah angkanya, lalu Run.
- Kalau salah satunya tidak diubah, batas yang lebih kecil yang berlaku. Kalau hanya `index.html` yang dinaikkan, teks panjang gagal disimpan dengan pesan "Gagal menyimpan".
- Untuk jawaban yang sangat panjang (cerita rinci, catatan harian kegiatan), lebih nyaman kalau klien mengunggahnya sebagai file Word.

### Catatan

- Klien sebaiknya menyimpan satu jawaban dulu sebelum mengisi kotak lain. Kalau ada beberapa kotak yang belum disimpan, lalu tombol Simpan di salah satunya ditekan, tulisan di kotak lain yang belum disimpan bisa hilang.
- Item `teks:` hanya bisa diatur saat membuat order. Template bawaan masih berisi unggah file saja.

---

## 6b. Fitur banyak file per item (`banyak:`)

Dipakai kalau klien harus mengirim beberapa file sekaligus di satu item, misalnya foto struktur organisasi desa.

### Pemasangan

1. Jalankan `migration-banyak.sql` di Supabase SQL Editor satu kali, **setelah** `schema.sql` dan `migration.sql`.
2. Ganti `index.html` dan `admin.html` di GitHub dengan versi terbaru, lalu tunggu 1 sampai 2 menit dan muat ulang dengan Ctrl + F5.

### Cara menulis daftar di halaman admin

```
Pedoman penulisan kampus (PDF)
banyak: Foto struktur organisasi desa
teks: Ceritakan gambaran desa kalian
```

Baris pertama satu file, baris kedua banyak file, baris ketiga jawaban teks. Tulisan `banyak:` hanya penanda dan tidak muncul di halaman klien.

### Yang dilihat klien

Tombol **Tambah file** membuka pilihan file dan klien bisa memilih beberapa file sekaligus (misalnya 10 foto sekali pilih). Selama mengunggah tampil kemajuan seperti "Mengunggah 3/10". Setiap file yang masuk muncul di daftar dengan tautan **hapus** kalau klien salah kirim. Item tercentang kalau minimal satu file sudah masuk. Klien bisa menekan **Tambah file** lagi kapan saja.

### Yang Anda lihat di admin

Setiap item menampilkan semua filenya, masing-masing dengan tombol **Unduh** sendiri.

### Batasan

- Maksimal 30 file per item dan 20 MB per file. File yang melebihi batas ditolak dan klien diberi tahu berapa yang gagal.
- Kalau klien menghapus file dari daftar, file itu hilang dari daftar tapi masih tersimpan di penyimpanan Supabase (klien tidak diberi izin menghapus file di penyimpanan demi keamanan). Ini sedikit memakai kuota dan bisa dibersihkan manual lewat **Storage** di Supabase.
- Saat Anda menghapus order lewat admin, file yang masih tercatat ikut terhapus, tapi file yatim bekas hapus oleh klien tetap perlu dibersihkan manual.
- Belum ada tombol unduh semua sebagai ZIP. Kalau butuh, lihat bagian 13.

---

## 7. Jenis file dan batasan

### Jenis file

Item yang tidak diawali `teks:` menjadi item unggah file, dan jenis filenya **tidak dibatasi**: Word (docx), PDF, Excel, PowerPoint, txt, htm, zip, rar, foto, gambar, dan lainnya.

Item biasa menampung satu file. Kalau klien perlu mengirim banyak file di satu item (misalnya foto struktur organisasi), awali barisnya dengan `banyak:` saat membuat order (lihat bagian 6b). Alternatifnya, minta klien menggabungkannya jadi satu zip, rar, atau PDF.

Kalau ingin membatasi jenis file untuk item tertentu (misalnya hanya PDF), tulis petunjuknya di nama item, contoh: "Pedoman kampus, format PDF". Sistem belum menolak format lain secara otomatis.

### Ukuran file

- **Maksimal 20 MB per file.** Batas ini ada di dua tempat:
  1. Pengaturan bucket di Supabase.
  2. Satu baris di `index.html` (`20*1024*1024`).
- Untuk menaikkannya, ubah dua-duanya. Di Supabase, buka **Storage**, klik titik tiga di bucket `berkas`, pilih **Edit bucket**, lalu ubah file size limit.
- Paket gratis Supabase punya batas sendiri per file (sekitar 50 MB), jadi lebih dari itu butuh paket berbayar.
- Paket gratis Supabase juga punya total penyimpanan sekitar 1 GB. Untuk dokumen biasanya cukup lama, tapi kalau banyak klien mengirim video atau file besar, kuotanya bisa cepat habis. Pantau di dashboard Supabase. Angka-angka ini bisa berubah, jadi cek halaman harga Supabase.

### Keamanan saat membuka file kiriman

Karena semua jenis file diterima, berhati-hatilah saat membuka file kiriman, terutama yang berekstensi `.exe`, `.htm`, atau arsip zip dan rar dari klien yang tidak Anda kenal. Berkas tersimpan aman di bucket privat dan tidak dijalankan oleh website, tapi file yang diunduh dan dibuka di komputer Anda tetap berisiko seperti file dari internet pada umumnya. Pastikan antivirus komputer aktif.

---

## 8. Urutan menjalankan SQL dan berkas mana yang perlu diunggah

- `migration.sql` adalah **tambahan** di atas `schema.sql`, bukan pengganti.
- Kalau `schema.sql` sudah pernah dijalankan dan portal sudah berfungsi, jalankan **hanya `migration.sql`**, satu kali.
- Menjalankan `schema.sql` ulang memunculkan error "already exists". Itu tidak merusak data, tapi tidak ada gunanya.
- Urutan baru berlaku kalau Anda membuat project Supabase baru dari nol (misalnya untuk usaha lain atau kalau project lama terhapus): jalankan berurutan `schema.sql`, lalu `migration.sql`, lalu `migration-banyak.sql`.
- Order lama tetap aman dan berjalan seperti biasa setelah migrasi.
- Mengunggah `schema.sql` dan `migration.sql` ke GitHub tidak wajib, tapi disarankan sebagai catatan dan cadangan cara membangun ulang database.
- Karena repo publik, isi berkas SQL bisa dibaca orang. Itu tidak berbahaya karena isinya hanya struktur tabel dan aturan akses, tanpa kata sandi atau kunci rahasia. Yang menjaga data klien adalah aturan keamanan di dalam Supabase, bukan kerahasiaan berkas itu.
- **Jangan pernah** menaruh kata sandi database atau kunci `service_role` di repo mana pun.

---

## 9. Memahami istilah: akun, organization, project, repositori

### Supabase

- **Akun**: login Anda.
- **Organization**: wadah pengelompokan, tempat tagihan dan anggota tim diatur. Anggap seperti folder besar. Kalau Anda bekerja sendiri, cukup satu organization dan hampir tidak perlu disentuh.
- **Project**: satu backend utuh yang berdiri sendiri, dengan database, penyimpanan file, dan daftar pengguna login sendiri. Data antar project tidak bercampur.

### GitHub

- **Akun**: login Anda.
- **Repositori**: menyimpan kode satu proyek.
- **Organization** di GitHub fungsinya sama seperti di Supabase: wadah untuk tim, tidak perlu dipakai kalau Anda sendirian.

### Hubungan keduanya

- **Project Supabase mirip repositori GitHub**, tapi isinya berbeda: repositori menyimpan kode, project Supabase menyimpan data dan file. Organization bukan padanan repositori, melainkan wadah yang menaungi project.
- Satu aplikasi biasanya berpasangan dengan satu repositori GitHub dan satu project Supabase. Keduanya tidak tersambung otomatis. Satu-satunya penghubungnya adalah `config.js`, yang berisi alamat dan kunci project Supabase.
- Kalau suatu hari Anda membuat aplikasi kedua yang tidak berhubungan, buat repositori baru dan project Supabase baru, lalu sambungkan lewat `config.js` miliknya sendiri. Portal ini tidak terganggu.
- Paket gratis Supabase membatasi jumlah project aktif (saat ini sekitar 2), dan project yang lama tidak dipakai bisa dijeda otomatis. Jangan membuat project percobaan yang tidak perlu. Batas ini bisa berubah, jadi cek halaman harga Supabase.

### Pertanyaan umum tentang organization Supabase

- **Apakah project bisa dikeluarkan dari organization?** Tidak. Setiap project wajib berada di dalam satu organization. Untuk pemakaian sendiri, organization tidak menambah biaya maupun pekerjaan, dan biasanya sudah dibuatkan otomatis saat mendaftar.
- **Mengganti nama organization**: **Organization settings > General**.
- **Memindahkan project ke organization lain**: **Project Settings > General > Transfer project**.
- **Menghapus organization**: hanya bisa kalau organization itu kosong tanpa project.
- **Apakah ada organization "private"?** Tidak ada pilihan privat atau publik di Supabase. Semua organization otomatis privat: isinya hanya bisa dilihat anggota yang Anda undang. Yang menentukan keamanan data adalah:
  1. **Daftar anggota**: cek di **Organization settings > Team** dan pastikan hanya akun Anda.
  2. **Penyimpanan file**: bucket `berkas` sudah privat dari `schema.sql`. Cek di **Storage**, seharusnya tidak ada label *Public* di sebelah bucket `berkas`.
  3. **Keamanan akun**: aktifkan verifikasi dua langkah (MFA) di **Account preferences** dan pakai kata sandi kuat.
- **Membuat organization baru yang terpisah**: klik nama organization di kiri atas, pilih **New organization**, isi nama, pilih tipe **Personal** kalau untuk sendiri, pilih paket **Free**, lalu **Create**. Project lama bisa dipindahkan lewat Transfer project. Untuk portal ini hal itu tidak perlu.

---

## 10. GitHub: publik atau privat, dan soal Vercel

### Publik atau privat

- Di GitHub, pilihan **Public** atau **Private** ada di tingkat **repositori**, bukan di organization atau akun. Bisa diubah nanti di **Settings > General**, bagian paling bawah (*Danger Zone*).
- Profil akun selalu terlihat publik, tapi isi repositori privat tidak.
- Untuk portal ini, repositori publik tidak berbahaya karena yang tersimpan hanya kode dan kunci anon yang memang boleh terbuka. Data dan file klien ada di Supabase.
- GitHub Pages versi gratis tidak bisa dipakai untuk repositori privat. Kalau Anda ingin repositori privat, tayangkan lewat **Netlify** atau **Cloudflare Pages**, yang bisa membaca repositori privat secara gratis.

### Menu "GitHub" dan "Vercel" di Supabase

Itu fitur integrasi (biasanya di **Project Settings > Integrations**) dan untuk portal ini **tidak perlu dipakai**.

- **GitHub di Supabase** menyambungkan project ke repositori supaya perubahan struktur database (migrasi) tercatat dan bisa dites di cabang terpisah. Ini untuk developer yang rutin mengubah database, dan fitur percabangannya berbayar.
- **Vercel di Supabase** mengisi alamat dan kunci Supabase otomatis ke project Vercel. Di portal ini hal itu sudah ditangani manual lewat `config.js`.

### Vercel

Vercel adalah layanan hosting, fungsinya sama seperti GitHub Pages: menayangkan website. Bedanya, Vercel menyambung ke repositori GitHub dan menayangkan ulang otomatis setiap kode berubah, dengan alamat bawaan berakhiran `.vercel.app`. Paket gratis Vercel (Hobby) ditujukan untuk pemakaian non-komersial. Karena portal ini untuk usaha jasa, lebih aman memakai GitHub Pages yang sudah terpasang, atau Netlify dan Cloudflare Pages. Syarat layanan bisa berubah, jadi cek halaman ketentuan masing-masing sebelum pindah.

---

## 11. Keamanan

- Kunci **anon** di `config.js` memang publik. Yang menjaga data adalah aturan akses (RLS) di `schema.sql` dan `migration.sql`.
- Klien hanya bisa membuka order miliknya lewat token acak 24 karakter. Jangan bagikan link ke orang lain.
- Bucket `berkas` bersifat privat. File hanya bisa diunduh lewat halaman admin setelah login.
- Pendaftaran umum dimatikan (langkah 7), jadi hanya akun yang Anda buat yang bisa masuk admin.
- Aktifkan verifikasi dua langkah (MFA) di akun Supabase dan GitHub, dan pakai kata sandi yang kuat.
- **Jangan pernah membagikan Database Password atau kunci `service_role`** ke siapa pun, dan jangan menaruhnya di repo.
- Jangan simpan berkas klien di repo GitHub.
- Berhati-hatilah saat membuka file kiriman klien (lihat bagian 7).

---

## 12. Jika ada masalah

### Tidak bisa masuk admin

Halaman admin menampilkan tulisan **"Gagal masuk: ..."** diikuti pesan error aslinya. Pastikan `admin.html` di GitHub sudah versi terbaru. Arti pesan yang mungkin muncul:

- **Invalid login credentials**: email atau sandi tidak cocok, atau user belum dikonfirmasi. Di Supabase, buka **Authentication > Users**, klik user Anda. Kalau kolom konfirmasi email kosong, hapus user itu lalu buat lagi dengan **Auto Confirm User** dicentang.
- **Email not confirmed**: sama, user belum dikonfirmasi.
- **Failed to fetch** atau **Invalid API key**: isi `config.js` salah, atau `config.js` yang sudah diedit belum diunggah ke GitHub. Mengedit berkas di komputer saja tidak cukup, berkasnya harus diunggah ulang.
- **Invalid path specified in request URL**: URL di `config.js` salah. Bentuk yang benar `https://xxxx.supabase.co` saja, tanpa tambahan `/rest/v1` atau garis miring di akhir.

Tiga penyebab paling sering:

1. `config.js` masih berisi tulisan `ISI-PROJECT-ID` karena belum diganti atau belum diunggah.
2. Yang disalin adalah kunci **service_role**, bukan anon atau publishable. Ganti dengan yang benar.
3. Browser masih menampilkan versi lama dari cache. Tekan **Ctrl + F5**.

### Masalah lain

- **Halaman kosong atau "Link tidak ditemukan"**: cek `config.js` (URL atau key salah salin), unggah ulang ke GitHub, lalu Ctrl + F5.
- **Gagal mengunggah file**: biasanya `schema.sql` belum berhasil dijalankan penuh. Jalankan lagi. Error "already exists" untuk bagian yang sudah terbuat itu wajar.
- **"Gagal menyimpan" pada isian teks**: biasanya `migration.sql` belum dijalankan, atau batas karakter di `index.html` lebih besar daripada di fungsi `save_text` (lihat bagian 6).
- **Item teks tidak muncul sebagai kotak ketik**: pastikan barisnya diawali `teks:` (huruf kecil, pakai titik dua) saat membuat order, dan `index.html` serta `admin.html` sudah versi terbaru.
- **Perubahan di GitHub belum terlihat**: tunggu 1 sampai 2 menit, lalu muat ulang dengan Ctrl + F5.

---

## 13. Fitur yang belum ada

Versi ini sengaja dibuat ringkas. Yang belum ada dan bisa ditambahkan nanti:

- Unduh semua berkas satu order sekaligus sebagai ZIP.
- Tempat Anda mengunggah hasil pekerjaan agar klien bisa mengunduhnya dari link yang sama.
- Kolom catatan per order.
- Penanda deadline yang mendekat.
- Pertanyaan teks yang tetap ada di template tertentu (misalnya "Ceritakan gambaran desa" selalu muncul di template KKN).
- Pembatasan jenis file per item.
- Menyimpan versi lama saat klien mengganti berkas (saat ini file lama tetap ada di penyimpanan, tapi tidak tampil di daftar).
