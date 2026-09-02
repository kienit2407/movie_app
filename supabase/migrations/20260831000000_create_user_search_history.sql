create table if not exists public.user_search_history (
  user_id uuid not null references auth.users(id) on delete cascade,
  keyword text not null check (char_length(btrim(keyword)) between 1 and 200),
  normalized_keyword text not null
    check (normalized_keyword = lower(btrim(keyword))),
  searched_at timestamptz not null default now(),
  primary key (user_id, normalized_keyword)
);

create index if not exists user_search_history_recent_idx
  on public.user_search_history(user_id, searched_at desc);

alter table public.user_search_history enable row level security;

drop policy if exists "Users can read their search history"
  on public.user_search_history;
create policy "Users can read their search history"
on public.user_search_history for select
using (auth.uid() = user_id);

drop policy if exists "Users can add their search history"
  on public.user_search_history;
create policy "Users can add their search history"
on public.user_search_history for insert
with check (auth.uid() = user_id);

drop policy if exists "Users can update their search history"
  on public.user_search_history;
create policy "Users can update their search history"
on public.user_search_history for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their search history"
  on public.user_search_history;
create policy "Users can delete their search history"
on public.user_search_history for delete
using (auth.uid() = user_id);

create or replace function public.trim_user_search_history()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.user_search_history as history
  where history.user_id = new.user_id
    and history.normalized_keyword in (
      select old_history.normalized_keyword
      from public.user_search_history as old_history
      where old_history.user_id = new.user_id
      order by old_history.searched_at desc, old_history.normalized_keyword
      offset 30
    );
  return new;
end;
$$;

drop trigger if exists trim_user_search_history_after_write
  on public.user_search_history;
create trigger trim_user_search_history_after_write
after insert or update on public.user_search_history
for each row execute procedure public.trim_user_search_history();

revoke all on public.user_search_history from anon, authenticated;
grant select, insert, update, delete
  on public.user_search_history to authenticated;
