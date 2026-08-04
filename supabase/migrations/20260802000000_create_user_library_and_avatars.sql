create table if not exists public.user_favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_slug text not null check (char_length(btrim(movie_slug)) between 1 and 255),
  name text not null,
  origin_name text not null default '',
  poster_url text not null default '',
  thumb_url text not null default '',
  episode_current text not null default '',
  quality text not null default '',
  lang text not null default '',
  year integer not null default 0,
  rating double precision,
  added_at timestamptz not null default now(),
  primary key (user_id, movie_slug)
);

create index if not exists user_favorites_recent_idx
  on public.user_favorites(user_id, added_at desc);

alter table public.user_favorites enable row level security;

drop policy if exists "Users can read their favorites" on public.user_favorites;
create policy "Users can read their favorites"
on public.user_favorites for select
using (auth.uid() = user_id);

drop policy if exists "Users can add their favorites" on public.user_favorites;
create policy "Users can add their favorites"
on public.user_favorites for insert
with check (auth.uid() = user_id);

drop policy if exists "Users can update their favorites" on public.user_favorites;
create policy "Users can update their favorites"
on public.user_favorites for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their favorites" on public.user_favorites;
create policy "Users can delete their favorites"
on public.user_favorites for delete
using (auth.uid() = user_id);

create table if not exists public.user_watch_history (
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_slug text not null check (char_length(btrim(movie_slug)) between 1 and 255),
  name text not null,
  origin_name text not null default '',
  poster_url text not null default '',
  thumb_url text not null default '',
  episode_current text not null default '',
  quality text not null default '',
  lang text not null default '',
  year integer not null default 0,
  rating double precision,
  movie_type text,
  category_id text,
  category_name text,
  position_ms bigint not null default 0 check (position_ms >= 0),
  duration_ms bigint not null default 0 check (duration_ms >= 0),
  last_server_index integer,
  last_episode_index integer,
  last_episode_name text,
  last_episode_link text,
  last_server_name text,
  watched_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, movie_slug)
);

create index if not exists user_watch_history_recent_idx
  on public.user_watch_history(user_id, watched_at desc);

alter table public.user_watch_history enable row level security;

drop policy if exists "Users can read their watch history" on public.user_watch_history;
create policy "Users can read their watch history"
on public.user_watch_history for select
using (auth.uid() = user_id);

drop policy if exists "Users can add their watch history" on public.user_watch_history;
create policy "Users can add their watch history"
on public.user_watch_history for insert
with check (auth.uid() = user_id);

drop policy if exists "Users can update their watch history" on public.user_watch_history;
create policy "Users can update their watch history"
on public.user_watch_history for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their watch history" on public.user_watch_history;
create policy "Users can delete their watch history"
on public.user_watch_history for delete
using (auth.uid() = user_id);

create or replace function public.trim_user_watch_history()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.user_watch_history as history
  where history.user_id = new.user_id
    and history.movie_slug in (
      select old_history.movie_slug
      from public.user_watch_history as old_history
      where old_history.user_id = new.user_id
      order by old_history.watched_at desc, old_history.movie_slug
      offset 100
    );
  return new;
end;
$$;

drop trigger if exists trim_user_watch_history_after_write
  on public.user_watch_history;
create trigger trim_user_watch_history_after_write
after insert or update on public.user_watch_history
for each row execute procedure public.trim_user_watch_history();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars',
  'avatars',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Avatar images are publicly readable" on storage.objects;
create policy "Avatar images are publicly readable"
on storage.objects for select
using (bucket_id = 'avatars');

drop policy if exists "Users can upload their avatar" on storage.objects;
create policy "Users can upload their avatar"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update their avatar" on storage.objects;
create policy "Users can update their avatar"
on storage.objects for update to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete their avatar" on storage.objects;
create policy "Users can delete their avatar"
on storage.objects for delete to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);
