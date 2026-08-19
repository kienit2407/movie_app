create table if not exists public.comment_notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null
    constraint comment_notifications_recipient_id_fkey
    references public.profiles(id) on delete cascade,
  actor_id uuid not null
    constraint comment_notifications_actor_id_fkey
    references public.profiles(id) on delete cascade,
  type text not null check (type in ('comment_reply', 'comment_reaction')),
  movie_slug text not null,
  comment_id uuid not null
    constraint comment_notifications_comment_id_fkey
    references public.movie_comments(id) on delete cascade,
  actor_name text not null,
  actor_avatar_url text,
  body_preview text not null default '',
  created_at timestamptz not null default now(),
  read_at timestamptz,
  unique (recipient_id, type, actor_id, comment_id)
);

create index if not exists comment_notifications_recipient_created_idx
  on public.comment_notifications(recipient_id, created_at desc);
create index if not exists comment_notifications_recipient_unread_idx
  on public.comment_notifications(recipient_id, created_at desc)
  where read_at is null;

alter table public.comment_notifications enable row level security;

drop policy if exists "Users read their own comment notifications"
  on public.comment_notifications;
create policy "Users read their own comment notifications"
on public.comment_notifications for select
to authenticated
using ((select auth.uid()) = recipient_id);

drop policy if exists "Users mark their own comment notifications read"
  on public.comment_notifications;
create policy "Users mark their own comment notifications read"
on public.comment_notifications for update
to authenticated
using ((select auth.uid()) = recipient_id)
with check ((select auth.uid()) = recipient_id);

revoke all on public.comment_notifications from anon, authenticated;
grant select on public.comment_notifications to authenticated;
grant update (read_at) on public.comment_notifications to authenticated;

create or replace function public.create_comment_reply_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_display_name text;
  actor_avatar text;
begin
  if new.parent_id is null
     or new.reply_to_user_id is null
     or new.reply_to_user_id = new.user_id then
    return new;
  end if;

  select profile.display_name, profile.avatar_url
  into actor_display_name, actor_avatar
  from public.profiles as profile
  where profile.id = new.user_id;

  insert into public.comment_notifications (
    recipient_id,
    actor_id,
    type,
    movie_slug,
    comment_id,
    actor_name,
    actor_avatar_url,
    body_preview
  ) values (
    new.reply_to_user_id,
    new.user_id,
    'comment_reply',
    new.movie_slug,
    new.id,
    coalesce(actor_display_name, 'Một người dùng'),
    actor_avatar,
    left(btrim(new.body), 160)
  )
  on conflict (recipient_id, type, actor_id, comment_id) do nothing;

  return new;
end;
$$;

drop trigger if exists create_comment_reply_notification_trigger
  on public.movie_comments;
create trigger create_comment_reply_notification_trigger
after insert on public.movie_comments
for each row execute procedure public.create_comment_reply_notification();

create or replace function public.sync_comment_reaction_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  reaction_comment_id uuid;
  reaction_actor_id uuid;
  recipient_user_id uuid;
  notification_movie_slug text;
  notification_body text;
  actor_display_name text;
  actor_avatar text;
begin
  if tg_op = 'DELETE' then
    reaction_comment_id := old.comment_id;
    reaction_actor_id := old.user_id;
    delete from public.comment_notifications
    where type = 'comment_reaction'
      and actor_id = reaction_actor_id
      and comment_id = reaction_comment_id;
    return old;
  end if;

  reaction_comment_id := new.comment_id;
  reaction_actor_id := new.user_id;

  if new.reaction <> 1 then
    delete from public.comment_notifications
    where type = 'comment_reaction'
      and actor_id = reaction_actor_id
      and comment_id = reaction_comment_id;
    return new;
  end if;

  select comment.user_id, comment.movie_slug, comment.body
  into recipient_user_id, notification_movie_slug, notification_body
  from public.movie_comments as comment
  where comment.id = reaction_comment_id
    and comment.deleted_at is null;

  if recipient_user_id is null or recipient_user_id = reaction_actor_id then
    return new;
  end if;

  select profile.display_name, profile.avatar_url
  into actor_display_name, actor_avatar
  from public.profiles as profile
  where profile.id = reaction_actor_id;

  insert into public.comment_notifications (
    recipient_id,
    actor_id,
    type,
    movie_slug,
    comment_id,
    actor_name,
    actor_avatar_url,
    body_preview
  ) values (
    recipient_user_id,
    reaction_actor_id,
    'comment_reaction',
    notification_movie_slug,
    reaction_comment_id,
    coalesce(actor_display_name, 'Một người dùng'),
    actor_avatar,
    left(btrim(notification_body), 160)
  )
  on conflict (recipient_id, type, actor_id, comment_id) do nothing;

  return new;
end;
$$;

drop trigger if exists sync_comment_reaction_notification_trigger
  on public.comment_reactions;
create trigger sync_comment_reaction_notification_trigger
after insert or update or delete on public.comment_reactions
for each row execute procedure public.sync_comment_reaction_notification();

do $$
begin
  alter publication supabase_realtime
    add table public.comment_notifications;
exception
  when duplicate_object then null;
end;
$$;

notify pgrst, 'reload schema';
