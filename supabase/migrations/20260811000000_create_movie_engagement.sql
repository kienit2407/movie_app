create table if not exists public.movie_engagement (
  movie_slug text primary key check (char_length(btrim(movie_slug)) between 1 and 255),
  name text not null default '',
  origin_name text not null default '',
  poster_url text not null default '',
  thumb_url text not null default '',
  episode_current text not null default '',
  quality text not null default '',
  lang text not null default '',
  year integer not null default 0,
  movie_type text not null default '',
  view_count bigint not null default 0 check (view_count >= 0),
  like_count bigint not null default 0 check (like_count >= 0),
  last_viewed_at timestamptz,
  last_liked_at timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists movie_engagement_top_views_idx
  on public.movie_engagement(view_count desc, like_count desc);

create index if not exists movie_engagement_type_top_views_idx
  on public.movie_engagement(movie_type, view_count desc, like_count desc);

alter table public.movie_engagement enable row level security;

drop policy if exists "Movie engagement is publicly readable"
  on public.movie_engagement;
create policy "Movie engagement is publicly readable"
on public.movie_engagement for select
using (true);

create or replace function public.record_movie_view(
  p_movie_slug text,
  p_name text default '',
  p_origin_name text default '',
  p_poster_url text default '',
  p_thumb_url text default '',
  p_episode_current text default '',
  p_quality text default '',
  p_lang text default '',
  p_year integer default 0,
  p_movie_type text default ''
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if char_length(btrim(p_movie_slug)) = 0 then
    raise exception 'movie_slug is required';
  end if;

  insert into public.movie_engagement (
    movie_slug,
    name,
    origin_name,
    poster_url,
    thumb_url,
    episode_current,
    quality,
    lang,
    year,
    movie_type,
    view_count,
    last_viewed_at,
    updated_at
  ) values (
    btrim(p_movie_slug),
    coalesce(p_name, ''),
    coalesce(p_origin_name, ''),
    coalesce(p_poster_url, ''),
    coalesce(p_thumb_url, ''),
    coalesce(p_episode_current, ''),
    coalesce(p_quality, ''),
    coalesce(p_lang, ''),
    coalesce(p_year, 0),
    coalesce(p_movie_type, ''),
    1,
    now(),
    now()
  )
  on conflict (movie_slug) do update set
    name = excluded.name,
    origin_name = excluded.origin_name,
    poster_url = excluded.poster_url,
    thumb_url = excluded.thumb_url,
    episode_current = excluded.episode_current,
    quality = excluded.quality,
    lang = excluded.lang,
    year = excluded.year,
    movie_type = excluded.movie_type,
    view_count = public.movie_engagement.view_count + 1,
    last_viewed_at = now(),
    updated_at = now();
end;
$$;

revoke all on function public.record_movie_view(
  text, text, text, text, text, text, text, text, integer, text
) from public;
grant execute on function public.record_movie_view(
  text, text, text, text, text, text, text, text, integer, text
) to anon, authenticated;

create or replace function public.sync_movie_favorite_engagement()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  like_increment integer := 0;
begin
  if tg_op = 'DELETE' then
    update public.movie_engagement
    set
      like_count = greatest(like_count - 1, 0),
      updated_at = now()
    where movie_slug = old.movie_slug;
    return old;
  end if;

  if tg_op = 'UPDATE' and old.movie_slug <> new.movie_slug then
    update public.movie_engagement
    set
      like_count = greatest(like_count - 1, 0),
      updated_at = now()
    where movie_slug = old.movie_slug;
  end if;

  if tg_op = 'INSERT' or
      (tg_op = 'UPDATE' and old.movie_slug <> new.movie_slug) then
    like_increment := 1;
  end if;

  insert into public.movie_engagement (
    movie_slug,
    name,
    origin_name,
    poster_url,
    thumb_url,
    episode_current,
    quality,
    lang,
    year,
    like_count,
    last_liked_at,
    updated_at
  ) values (
    new.movie_slug,
    new.name,
    new.origin_name,
    new.poster_url,
    new.thumb_url,
    new.episode_current,
    new.quality,
    new.lang,
    new.year,
    like_increment,
    now(),
    now()
  )
  on conflict (movie_slug) do update set
    name = excluded.name,
    origin_name = excluded.origin_name,
    poster_url = excluded.poster_url,
    thumb_url = excluded.thumb_url,
    episode_current = excluded.episode_current,
    quality = excluded.quality,
    lang = excluded.lang,
    year = excluded.year,
    like_count = public.movie_engagement.like_count + like_increment,
    last_liked_at = now(),
    updated_at = now();
  return new;
end;
$$;

drop trigger if exists sync_movie_favorite_engagement_trigger
  on public.user_favorites;
create trigger sync_movie_favorite_engagement_trigger
after insert or update or delete on public.user_favorites
for each row execute procedure public.sync_movie_favorite_engagement();

insert into public.movie_engagement (
  movie_slug,
  name,
  origin_name,
  poster_url,
  thumb_url,
  episode_current,
  quality,
  lang,
  year,
  like_count,
  last_liked_at,
  updated_at
)
select
  movie_slug,
  max(name),
  max(origin_name),
  max(poster_url),
  max(thumb_url),
  max(episode_current),
  max(quality),
  max(lang),
  max(year),
  count(*),
  max(added_at),
  now()
from public.user_favorites
group by movie_slug
on conflict (movie_slug) do update set
  name = excluded.name,
  origin_name = excluded.origin_name,
  poster_url = excluded.poster_url,
  thumb_url = excluded.thumb_url,
  episode_current = excluded.episode_current,
  quality = excluded.quality,
  lang = excluded.lang,
  year = excluded.year,
  like_count = excluded.like_count,
  last_liked_at = excluded.last_liked_at,
  updated_at = now();
