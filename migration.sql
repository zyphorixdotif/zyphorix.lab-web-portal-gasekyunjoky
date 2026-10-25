-- Jalankan sekali di Supabase SQL Editor (setelah schema.sql). Menambah fitur isian teks.
alter table items add column if not exists tipe text not null default 'file';
alter table items add column if not exists jawaban text;

create or replace function get_order(p_token text) returns json language sql security definer set search_path=public as $$
  select json_build_object('klien',o.klien,'layanan',o.layanan,'judul',o.judul,'deadline',o.deadline,'status',o.status,
   'items',(select coalesce(json_agg(json_build_object('id',i.id,'nama',i.nama,'petunjuk',i.petunjuk,'tipe',i.tipe,'jawaban',i.jawaban,'file_name',i.file_name,'uploaded_at',i.uploaded_at) order by i.urut),'[]'::json) from items i where i.order_id=o.id))
  from orders o where o.token=p_token $$;

create or replace function mark_uploaded(p_token text,p_item uuid,p_path text,p_name text) returns void language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  select o.id into v from orders o join items i on i.order_id=o.id where o.token=p_token and i.id=p_item;
  if v is null or p_path not like p_item::text||'/%' then raise exception 'tidak valid'; end if;
  update items set file_path=p_path,file_name=p_name,uploaded_at=now() where id=p_item;
  if not exists(select 1 from items where order_id=v and ((tipe='file' and file_path is null) or (tipe='teks' and coalesce(jawaban,'')=''))) then
    update orders set status='Berkas lengkap' where id=v and status='Menunggu berkas';
  end if;
end $$;

create or replace function save_text(p_token text,p_item uuid,p_text text) returns void language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  select o.id into v from orders o join items i on i.order_id=o.id where o.token=p_token and i.id=p_item and i.tipe='teks';
  if v is null or length(p_text)>5000 then raise exception 'tidak valid'; end if;
  update items set jawaban=nullif(trim(p_text),''),uploaded_at=case when trim(p_text)='' then null else now() end where id=p_item;
  if not exists(select 1 from items where order_id=v and ((tipe='file' and file_path is null) or (tipe='teks' and coalesce(jawaban,'')=''))) then
    update orders set status='Berkas lengkap' where id=v and status='Menunggu berkas';
  end if;
end $$;
grant execute on function get_order(text), mark_uploaded(text,uuid,text,text), save_text(text,uuid,text) to anon;
