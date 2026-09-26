alter table public.profiles
  add column if not exists cover_url text;

create or replace function public.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  resolved_name text;
  resolved_avatar text;
  resolved_cover text;
begin
  resolved_name := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''),
    nullif(btrim(new.raw_user_meta_data ->> 'name'), ''),
    nullif(btrim(new.raw_user_meta_data ->> 'user_name'), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'Người dùng'
  );
  resolved_avatar := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'avatar_url'), ''),
    nullif(btrim(new.raw_user_meta_data ->> 'picture'), '')
  );
  resolved_cover := nullif(
    btrim(new.raw_user_meta_data ->> 'cover_url'),
    ''
  );

  insert into public.profiles (id, display_name, avatar_url, cover_url)
  values (new.id, resolved_name, resolved_avatar, resolved_cover)
  on conflict (id) do nothing;

  return new;
end;
$$;

grant insert (id, display_name, avatar_url, cover_url, updated_at)
  on public.profiles to authenticated;
grant update (display_name, avatar_url, cover_url, updated_at)
  on public.profiles to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-covers',
  'profile-covers',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Profile cover images are publicly readable"
  on storage.objects;
create policy "Profile cover images are publicly readable"
on storage.objects for select
using (bucket_id = 'profile-covers');

drop policy if exists "Users can upload their profile cover"
  on storage.objects;
create policy "Users can upload their profile cover"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'profile-covers'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update their profile cover"
  on storage.objects;
create policy "Users can update their profile cover"
on storage.objects for update to authenticated
using (
  bucket_id = 'profile-covers'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-covers'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete their profile cover"
  on storage.objects;
create policy "Users can delete their profile cover"
on storage.objects for delete to authenticated
using (
  bucket_id = 'profile-covers'
  and (storage.foldername(name))[1] = auth.uid()::text
);
