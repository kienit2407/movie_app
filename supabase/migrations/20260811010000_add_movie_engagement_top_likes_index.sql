create index if not exists movie_engagement_top_likes_idx
  on public.movie_engagement(like_count desc, view_count desc)
  where like_count > 0;
