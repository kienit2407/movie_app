alter table public.movie_comments
  add column if not exists reply_to_comment_id uuid;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'movie_comments_reply_to_comment_id_fkey'
      and conrelid = 'public.movie_comments'::regclass
  ) then
    alter table public.movie_comments
      add constraint movie_comments_reply_to_comment_id_fkey
      foreign key (reply_to_comment_id)
      references public.movie_comments(id)
      on delete set null;
  end if;
end;
$$;

update public.movie_comments
set reply_to_comment_id = parent_id
where parent_id is not null
  and reply_to_comment_id is null;

create index if not exists movie_comments_reply_target_idx
  on public.movie_comments(reply_to_comment_id, created_at);

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

grant insert (reply_to_comment_id)
  on public.movie_comments to authenticated;

create or replace function public.get_comment_replies_v2(
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
    coalesce(child_counts.reply_count, 0),
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
    from public.movie_comments as child
    where child.reply_to_comment_id = comment.id
  ) as child_counts on true
  left join public.comment_reactions as viewer
    on viewer.comment_id = comment.id
    and viewer.user_id = auth.uid()
  where comment.parent_id = p_root_comment_id
  order by comment.created_at asc
  limit greatest(1, least(p_limit, 100))
  offset greatest(p_offset, 0);
$$;

revoke all on function public.get_comment_replies_v2(
  uuid,
  integer,
  integer
) from public;
grant execute on function public.get_comment_replies_v2(
  uuid,
  integer,
  integer
) to anon, authenticated;

notify pgrst, 'reload schema';
