create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  resolved_name text;
  resolved_avatar text;
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

  insert into public.profiles (id, display_name, avatar_url)
  values (new.id, resolved_name, resolved_avatar)
  on conflict (id) do update
  set
    display_name = excluded.display_name,
    avatar_url = excluded.avatar_url,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_profile_sync on auth.users;
create trigger on_auth_user_profile_sync
after insert or update of raw_user_meta_data, email on auth.users
for each row execute procedure public.sync_profile_from_auth();

insert into public.profiles (id, display_name, avatar_url)
select
  users.id,
  coalesce(
    nullif(btrim(users.raw_user_meta_data ->> 'full_name'), ''),
    nullif(btrim(users.raw_user_meta_data ->> 'name'), ''),
    nullif(btrim(users.raw_user_meta_data ->> 'user_name'), ''),
    nullif(split_part(coalesce(users.email, ''), '@', 1), ''),
    'Người dùng'
  ),
  coalesce(
    nullif(btrim(users.raw_user_meta_data ->> 'avatar_url'), ''),
    nullif(btrim(users.raw_user_meta_data ->> 'picture'), '')
  )
from auth.users as users
on conflict (id) do update
set
  display_name = excluded.display_name,
  avatar_url = excluded.avatar_url,
  updated_at = now();

create table if not exists public.movie_comments (
  id uuid primary key default gen_random_uuid(),
  movie_slug text not null check (char_length(btrim(movie_slug)) between 1 and 255),
  user_id uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.movie_comments(id) on delete cascade,
  reply_to_user_id uuid references public.profiles(id) on delete set null,
  reply_to_comment_id uuid references public.movie_comments(id) on delete set null,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz,
  constraint movie_comments_body_length check (
    deleted_at is not null
    or char_length(btrim(body)) between 1 and 2000
  )
);

create table if not exists public.comment_reactions (
  comment_id uuid not null references public.movie_comments(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  reaction smallint not null check (reaction in (-1, 1)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (comment_id, user_id)
);

create table if not exists public.comment_reports (
  id uuid primary key default gen_random_uuid(),
  comment_id uuid not null references public.movie_comments(id) on delete cascade,
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (
    reason in ('spam', 'harassment', 'spoiler', 'inappropriate', 'other')
  ),
  created_at timestamptz not null default now(),
  unique (comment_id, reporter_id)
);

create index if not exists movie_comments_movie_created_idx
  on public.movie_comments(movie_slug, created_at desc)
  where parent_id is null;
create index if not exists movie_comments_parent_created_idx
  on public.movie_comments(parent_id, created_at);
create index if not exists movie_comments_reply_target_idx
  on public.movie_comments(reply_to_comment_id, created_at);
create index if not exists movie_comments_user_idx
  on public.movie_comments(user_id);
create index if not exists comment_reactions_comment_idx
  on public.comment_reactions(comment_id, reaction);
create index if not exists comment_reports_comment_idx
  on public.comment_reports(comment_id);

create or replace function public.validate_movie_comment_thread()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  root_slug text;
  root_parent uuid;
  target_slug text;
  target_parent uuid;
  target_user_id uuid;
begin
  if new.parent_id is null then
    new.reply_to_user_id := null;
    new.reply_to_comment_id := null;
    return new;
  end if;

  select comment.movie_slug, comment.parent_id
  into root_slug, root_parent
  from public.movie_comments as comment
  where comment.id = new.parent_id;

  if root_slug is null then
    raise exception 'Parent comment does not exist';
  end if;
  if root_parent is not null then
    raise exception 'Replies must point to a root comment';
  end if;
  if root_slug <> new.movie_slug then
    raise exception 'Reply and root comment must belong to the same movie';
  end if;

  if new.reply_to_comment_id is null then
    new.reply_to_comment_id := new.parent_id;
  end if;

  select comment.movie_slug, comment.parent_id, comment.user_id
  into target_slug, target_parent, target_user_id
  from public.movie_comments as comment
  where comment.id = new.reply_to_comment_id;

  if target_slug is null then
    raise exception 'Reply target does not exist';
  end if;
  if target_slug <> new.movie_slug then
    raise exception 'Reply target must belong to the same movie';
  end if;
  if new.reply_to_comment_id <> new.parent_id
     and target_parent is distinct from new.parent_id then
    raise exception 'Reply target must belong to the same thread';
  end if;

  new.reply_to_user_id := target_user_id;
  return new;
end;
$$;

drop trigger if exists validate_movie_comment_thread_trigger
  on public.movie_comments;
create trigger validate_movie_comment_thread_trigger
before insert or update of
  parent_id,
  reply_to_comment_id,
  reply_to_user_id,
  movie_slug
on public.movie_comments
for each row execute procedure public.validate_movie_comment_thread();

create or replace function public.touch_movie_comment()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  if new.body is distinct from old.body and new.deleted_at is null then
    new.edited_at := now();
  end if;
  if new.deleted_at is not null and old.deleted_at is null then
    new.body := '';
  end if;
  return new;
end;
$$;

drop trigger if exists touch_movie_comment_trigger on public.movie_comments;
create trigger touch_movie_comment_trigger
before update on public.movie_comments
for each row execute procedure public.touch_movie_comment();

create or replace function public.touch_comment_reaction()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists touch_comment_reaction_trigger
  on public.comment_reactions;
create trigger touch_comment_reaction_trigger
before update on public.comment_reactions
for each row execute procedure public.touch_comment_reaction();

alter table public.profiles enable row level security;
alter table public.movie_comments enable row level security;
alter table public.comment_reactions enable row level security;
alter table public.comment_reports enable row level security;

drop policy if exists "Profiles are publicly readable" on public.profiles;
create policy "Profiles are publicly readable"
on public.profiles for select
to anon, authenticated
using (true);

drop policy if exists "Comments are publicly readable" on public.movie_comments;
create policy "Comments are publicly readable"
on public.movie_comments for select
to anon, authenticated
using (true);

drop policy if exists "Authenticated users create comments"
  on public.movie_comments;
create policy "Authenticated users create comments"
on public.movie_comments for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Owners update comments" on public.movie_comments;
create policy "Owners update comments"
on public.movie_comments for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Reactions are publicly readable"
  on public.comment_reactions;
create policy "Reactions are publicly readable"
on public.comment_reactions for select
to anon, authenticated
using (true);

drop policy if exists "Users create their own reactions"
  on public.comment_reactions;
create policy "Users create their own reactions"
on public.comment_reactions for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users update their own reactions"
  on public.comment_reactions;
create policy "Users update their own reactions"
on public.comment_reactions for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users delete their own reactions"
  on public.comment_reactions;
create policy "Users delete their own reactions"
on public.comment_reactions for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users create their own reports"
  on public.comment_reports;
create policy "Users create their own reports"
on public.comment_reports for insert
to authenticated
with check ((select auth.uid()) = reporter_id);

revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to anon, authenticated;

revoke all on public.movie_comments from anon, authenticated;
grant select on public.movie_comments to anon, authenticated;
grant insert (
  movie_slug,
  user_id,
  parent_id,
  reply_to_user_id,
  reply_to_comment_id,
  body
)
  on public.movie_comments to authenticated;
grant update (body, deleted_at)
  on public.movie_comments to authenticated;

revoke all on public.comment_reactions from anon, authenticated;
grant select on public.comment_reactions to anon, authenticated;
grant insert (comment_id, user_id, reaction)
  on public.comment_reactions to authenticated;
grant update (reaction) on public.comment_reactions to authenticated;
grant delete on public.comment_reactions to authenticated;

revoke all on public.comment_reports from anon, authenticated;
grant insert (comment_id, reporter_id, reason)
  on public.comment_reports to authenticated;

create or replace function public.get_movie_comment_count(p_movie_slug text)
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)
  from public.movie_comments as comment
  where comment.movie_slug = p_movie_slug
    and comment.deleted_at is null;
$$;

create or replace function public.get_movie_comments(
  p_movie_slug text,
  p_sort text default 'popular',
  p_limit integer default 20,
  p_offset integer default 0
)
returns table (
  id uuid,
  movie_slug text,
  user_id uuid,
  parent_id uuid,
  reply_to_user_id uuid,
  reply_to_comment_id uuid,
  body text,
  created_at timestamptz,
  updated_at timestamptz,
  edited_at timestamptz,
  deleted_at timestamptz,
  author_name text,
  author_avatar_url text,
  reply_to_name text,
  like_count bigint,
  dislike_count bigint,
  reply_count bigint,
  viewer_reaction smallint
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    comment.id,
    comment.movie_slug,
    comment.user_id,
    comment.parent_id,
    comment.reply_to_user_id,
    comment.reply_to_comment_id,
    comment.body,
    comment.created_at,
    comment.updated_at,
    comment.edited_at,
    comment.deleted_at,
    profile.display_name,
    profile.avatar_url,
    reply_profile.display_name,
    coalesce(reaction_counts.like_count, 0),
    coalesce(reaction_counts.dislike_count, 0),
    coalesce(reply_counts.reply_count, 0),
    coalesce(viewer.reaction, 0)::smallint
  from public.movie_comments as comment
  join public.profiles as profile on profile.id = comment.user_id
  left join public.profiles as reply_profile
    on reply_profile.id = comment.reply_to_user_id
  left join lateral (
    select
      count(*) filter (where reaction.reaction = 1) as like_count,
      count(*) filter (where reaction.reaction = -1) as dislike_count
    from public.comment_reactions as reaction
    where reaction.comment_id = comment.id
  ) as reaction_counts on true
  left join lateral (
    select count(*) as reply_count
    from public.movie_comments as reply
    where reply.parent_id = comment.id
  ) as reply_counts on true
  left join public.comment_reactions as viewer
    on viewer.comment_id = comment.id
    and viewer.user_id = auth.uid()
  where comment.movie_slug = p_movie_slug
    and comment.parent_id is null
  order by
    case when p_sort = 'popular'
      then coalesce(reaction_counts.like_count, 0) end desc,
    case when p_sort = 'popular'
      then coalesce(reply_counts.reply_count, 0) end desc,
    comment.created_at desc
  limit greatest(1, least(p_limit, 50))
  offset greatest(p_offset, 0);
$$;

create or replace function public.get_comment_replies(
  p_root_comment_id uuid,
  p_limit integer default 30,
  p_offset integer default 0
)
returns table (
  id uuid,
  movie_slug text,
  user_id uuid,
  parent_id uuid,
  reply_to_user_id uuid,
  reply_to_comment_id uuid,
  body text,
  created_at timestamptz,
  updated_at timestamptz,
  edited_at timestamptz,
  deleted_at timestamptz,
  author_name text,
  author_avatar_url text,
  reply_to_name text,
  like_count bigint,
  dislike_count bigint,
  reply_count bigint,
  viewer_reaction smallint
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    comment.id,
    comment.movie_slug,
    comment.user_id,
    comment.parent_id,
    comment.reply_to_user_id,
    comment.reply_to_comment_id,
    comment.body,
    comment.created_at,
    comment.updated_at,
    comment.edited_at,
    comment.deleted_at,
    profile.display_name,
    profile.avatar_url,
    reply_profile.display_name,
    coalesce(reaction_counts.like_count, 0),
    coalesce(reaction_counts.dislike_count, 0),
    0::bigint,
    coalesce(viewer.reaction, 0)::smallint
  from public.movie_comments as comment
  join public.profiles as profile on profile.id = comment.user_id
  left join public.profiles as reply_profile
    on reply_profile.id = comment.reply_to_user_id
  left join lateral (
    select
      count(*) filter (where reaction.reaction = 1) as like_count,
      count(*) filter (where reaction.reaction = -1) as dislike_count
    from public.comment_reactions as reaction
    where reaction.comment_id = comment.id
  ) as reaction_counts on true
  left join public.comment_reactions as viewer
    on viewer.comment_id = comment.id
    and viewer.user_id = auth.uid()
  where comment.parent_id = p_root_comment_id
  order by comment.created_at asc
  limit greatest(1, least(p_limit, 100))
  offset greatest(p_offset, 0);
$$;

create or replace function public.set_comment_reaction(
  p_comment_id uuid,
  p_reaction smallint
)
returns table (
  like_count bigint,
  dislike_count bigint,
  viewer_reaction smallint
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication required';
  end if;
  if p_reaction not in (-1, 0, 1) then
    raise exception 'Invalid reaction';
  end if;
  if not exists (
    select 1
    from public.movie_comments as comment
    where comment.id = p_comment_id
      and comment.deleted_at is null
  ) then
    raise exception 'Comment not found';
  end if;

  if p_reaction = 0 then
    delete from public.comment_reactions
    where comment_id = p_comment_id
      and user_id = current_user_id;
  else
    insert into public.comment_reactions (comment_id, user_id, reaction)
    values (p_comment_id, current_user_id, p_reaction)
    on conflict (comment_id, user_id) do update
    set reaction = excluded.reaction;
  end if;

  return query
  select
    count(*) filter (where reaction.reaction = 1),
    count(*) filter (where reaction.reaction = -1),
    coalesce(
      max(reaction.reaction) filter (
        where reaction.user_id = current_user_id
      ),
      0
    )::smallint
  from public.comment_reactions as reaction
  where reaction.comment_id = p_comment_id;
end;
$$;

revoke all on function public.get_movie_comment_count(text) from public;
revoke all on function public.get_movie_comments(text, text, integer, integer)
  from public;
revoke all on function public.get_comment_replies(uuid, integer, integer)
  from public;
revoke all on function public.set_comment_reaction(uuid, smallint)
  from public;

grant execute on function public.get_movie_comment_count(text)
  to anon, authenticated;
grant execute on function public.get_movie_comments(text, text, integer, integer)
  to anon, authenticated;
grant execute on function public.get_comment_replies(uuid, integer, integer)
  to anon, authenticated;
grant execute on function public.set_comment_reaction(uuid, smallint)
  to authenticated;
