-- FUSIÓN STORE: configuración de base de datos y permisos.
-- ANTES DE EJECUTAR: reemplaza admin@tudominio.com por el correo exacto de tu administrador.
-- Ejecuta todo este archivo en Supabase > SQL Editor > New query.

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 100),
  description text not null default '',
  price numeric(12,2) not null default 0 check (price >= 0),
  category text not null default 'Otros',
  image_url text not null default '',
  available boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;

-- El público puede ver el catálogo. Solo el correo autorizado puede crear, editar o eliminar.
drop policy if exists "Public can view products" on public.products;
create policy "Public can view products" on public.products
for select to anon, authenticated using (true);

drop policy if exists "Only store admin can insert products" on public.products;
create policy "Only store admin can insert products" on public.products
for insert to authenticated
with check ((auth.jwt() ->> 'email') = 'admin@tudominio.com');

drop policy if exists "Only store admin can update products" on public.products;
create policy "Only store admin can update products" on public.products
for update to authenticated
using ((auth.jwt() ->> 'email') = 'admin@tudominio.com')
with check ((auth.jwt() ->> 'email') = 'admin@tudominio.com');

drop policy if exists "Only store admin can delete products" on public.products;
create policy "Only store admin can delete products" on public.products
for delete to authenticated
using ((auth.jwt() ->> 'email') = 'admin@tudominio.com');

grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;

-- Crea antes el bucket público llamado exactamente product-images en Storage.
-- Después de crearlo, aplica estas políticas para que solo el administrador suba o borre fotos.
drop policy if exists "Public can view product images" on storage.objects;
create policy "Public can view product images" on storage.objects
for select to anon, authenticated
using (bucket_id = 'product-images');

drop policy if exists "Only store admin can upload product images" on storage.objects;
create policy "Only store admin can upload product images" on storage.objects
for insert to authenticated
with check (bucket_id = 'product-images' and (auth.jwt() ->> 'email') = 'admin@tudominio.com');

drop policy if exists "Only store admin can update product images" on storage.objects;
create policy "Only store admin can update product images" on storage.objects
for update to authenticated
using (bucket_id = 'product-images' and (auth.jwt() ->> 'email') = 'admin@tudominio.com')
with check (bucket_id = 'product-images' and (auth.jwt() ->> 'email') = 'admin@tudominio.com');

drop policy if exists "Only store admin can delete product images" on storage.objects;
create policy "Only store admin can delete product images" on storage.objects
for delete to authenticated
using (bucket_id = 'product-images' and (auth.jwt() ->> 'email') = 'admin@tudominio.com');
