-- Jalankan sekali di Supabase SQL Editor, SETELAH schema.sql dan migration.sql.
-- Menambah fitur banyak file per item (awalan "banyak:" saat membuat order).
create table if not exists item_files(
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references items on delete cascade,
  file_path text not null, file_name text not null,
  uploaded_at timestamptz default now());
alter table item_files enable row level security;
create policy admin_item_files on item_files for all to authenticated using(true) with check(true);

create or replace function order_lengkap(v uuid) returns boolean language sql stable as $$
  select not exists(select 1 from items i where i.order_id=v and (
    (i.tipe='file' and i.file_path is null) or
    (i.tipe='teks' and coalesce(i.jawaban,'')='') or
    (i.tipe='banyak' and not exists(select 1 from item_files f where f.item_id=i.id)))) $$;

create or replace function get_order(p_token text) returns json language sql security definer set search_path=public as $$
  select json_build_object('klien',o.klien,'layanan',o.layanan,'judul',o.judul,'deadline',o.deadline,'status',o.status,
   'items',(select coalesce(json_agg(json_build_object('id',i.id,'nama',i.nama,'petunjuk',i.petunjuk,'tipe',i.tipe,'jawaban',i.jawaban,'file_name',i.file_name,'uploaded_at',i.uploaded_at,
     'files',(select coalesce(json_agg(json_build_object('id',f.id,'name',f.file_name) order by f.uploaded_at),'[]'::json) from item_files f where f.item_id=i.id)) order by i.urut),'[]'::json) from items i where i.order_id=o.id))
  from orders o where o.token=p_token $$;

create or replace function mark_uploaded(p_token text,p_item uuid,p_path text,p_name text) returns void language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  select o.id into v from orders o join items i on i.order_id=o.id where o.token=p_token and i.id=p_item and i.tipe='file';
  if v is null or p_path not like p_item::text||'/%' then raise exception 'tidak valid'; end if;
  update items set file_path=p_path,file_name=p_name,uploaded_at=now() where id=p_item;
  if order_lengkap(v) then update orders set status='Berkas lengkap' where id=v and status='Menunggu berkas'; end if;
end $$;

create or replace function save_text(p_token text,p_item uuid,p_text text) returns void language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  select o.id into v from orders o join items i on i.order_id=o.id where o.token=p_token and i.id=p_item and i.tipe='teks';
  if v is null or length(p_text)>5000 then raise exception 'tidak valid'; end if;
  update items set jawaban=nullif(trim(p_text),''),uploaded_at=case when trim(p_text)='' then null else now() end where id=p_item;
  if order_lengkap(v) then update orders set status='Berkas lengkap' where id=v and status='Menunggu berkas'; end if;
end $$;

create or replace function add_file(p_token text,p_item uuid,p_path text,p_name text) returns void language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  select o.id into v from orders o join items i on i.order_id=o.id where o.token=p_token and i.id=p_item and i.tipe='banyak';
  if v is null or p_path not like p_item::text||'/%' then raise exception 'tidak valid'; end if;
  if (select count(*) from item_files where item_id=p_item)>=30 then raise exception 'terlalu banyak'; end if;
  insert into item_files(item_id,file_path,file_name) values(p_item,p_path,p_name);
  if order_lengkap(v) then update orders set status='Berkas lengkap' where id=v and status='Menunggu berkas'; end if;
end $$;

create or replace function remove_file(p_token text,p_file uuid) returns void language sql security definer set search_path=public as $$
  delete from item_files f using items i, orders o where f.id=p_file and i.id=f.item_id and o.id=i.order_id and o.token=p_token $$;

grant execute on function get_order(text), mark_uploaded(text,uuid,text,text), save_text(text,uuid,text), add_file(text,uuid,text,text), remove_file(text,uuid) to anon;
