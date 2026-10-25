-- Jalankan sekali di Supabase: SQL Editor > New query > Run
create extension if not exists pgcrypto;

create table orders(
  id uuid primary key default gen_random_uuid(),
  token text unique not null default encode(gen_random_bytes(12),'hex'),
  klien text not null, layanan text, judul text, deadline date,
  status text not null default 'Menunggu berkas',
  created_at timestamptz default now());

create table items(
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders on delete cascade,
  nama text not null, petunjuk text, urut int default 0,
  file_path text, file_name text, uploaded_at timestamptz);

create table templates(id serial primary key, nama text unique not null, items text[] not null);

alter table orders enable row level security;
alter table items enable row level security;
alter table templates enable row level security;
create policy admin_orders on orders for all to authenticated using(true) with check(true);
create policy admin_items on items for all to authenticated using(true) with check(true);
create policy admin_tpl on templates for all to authenticated using(true) with check(true);

insert into templates(nama,items) values
('Skripsi',array['Pedoman penulisan kampus (PDF)','Judul / topik yang disetujui','Hasil bimbingan terakhir','Data atau bahan penelitian','Contoh skripsi kakak tingkat (jika ada)']),
('Makalah / Esai',array['Instruksi dari dosen','Mata kuliah dan topik','Format yang diminta (halaman, font, spasi)','Referensi dari dosen (jika ada)']),
('Artikel Ilmiah',array['Naskah atau outline awal','Template jurnal tujuan','Data penelitian']),
('KKN',array['Panduan KKN dari kampus','Data kelompok dan lokasi','Dokumentasi kegiatan','Catatan harian kegiatan']);

-- Penyimpanan file (privat, maks 20 MB per file)
insert into storage.buckets(id,name,public,file_size_limit) values('berkas','berkas',false,20971520) on conflict do nothing;
create policy klien_upload on storage.objects for insert to anon with check(bucket_id='berkas');
create policy admin_files on storage.objects for all to authenticated using(bucket_id='berkas') with check(bucket_id='berkas');

-- Fungsi untuk halaman klien (hanya bisa diakses lewat token)
create function get_order(p_token text) returns json language sql security definer set search_path=public as $$
  select json_build_object('klien',o.klien,'layanan',o.layanan,'judul',o.judul,'deadline',o.deadline,'status',o.status,
   'items',(select coalesce(json_agg(json_build_object('id',i.id,'nama',i.nama,'petunjuk',i.petunjuk,'file_name',i.file_name,'uploaded_at',i.uploaded_at) order by i.urut),'[]'::json) from items i where i.order_id=o.id))
  from orders o where o.token=p_token $$;

create function mark_uploaded(p_token text,p_item uuid,p_path text,p_name text) returns void language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  select o.id into v from orders o join items i on i.order_id=o.id where o.token=p_token and i.id=p_item;
  if v is null or p_path not like p_item::text||'/%' then raise exception 'tidak valid'; end if;
  update items set file_path=p_path,file_name=p_name,uploaded_at=now() where id=p_item;
  if not exists(select 1 from items where order_id=v and file_path is null) then
    update orders set status='Berkas lengkap' where id=v and status='Menunggu berkas';
  end if;
end $$;
grant execute on function get_order(text), mark_uploaded(text,uuid,text,text) to anon;
