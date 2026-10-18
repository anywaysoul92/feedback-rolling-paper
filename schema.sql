-- 현재 Supabase DB 구조 재현용 스크립트 (이미 적용됨, 새 프로젝트에 복구할 때만 사용)
create table public.feedback (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  dept text not null check (char_length(dept) between 1 and 30),
  author text not null default '익명' check (char_length(author) between 1 and 20),
  category text not null check (category in ('good', 'improve')),
  content text not null check (char_length(content) between 1 and 200),
  edited_at timestamptz
);
alter table public.feedback enable row level security;
create policy "anyone can read" on public.feedback for select to anon using (true);

create table public.feedback_owner (
  feedback_id bigint primary key references public.feedback(id) on delete cascade,
  token uuid not null
);
alter table public.feedback_owner enable row level security;
revoke all on public.feedback_owner from anon, authenticated;
revoke insert, update, delete on public.feedback from anon, authenticated;

create table public.rating (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  dept text not null check (char_length(dept) between 1 and 30),
  q1 smallint not null check (q1 between 1 and 5),
  q2 smallint not null check (q2 between 1 and 5)
);
alter table public.rating enable row level security;
create policy "anyone can read rating" on public.rating for select to anon using (true);
create policy "anyone can insert rating" on public.rating for insert to anon with check (true);

create function public.add_feedback(p_dept text, p_author text, p_category text, p_content text, p_token uuid)
returns public.feedback
language plpgsql security definer set search_path = public as $$
declare r public.feedback;
begin
  insert into public.feedback(dept, author, category, content)
  values (p_dept, coalesce(nullif(p_author, ''), '익명'), p_category, p_content)
  returning * into r;
  insert into public.feedback_owner(feedback_id, token) values (r.id, p_token);
  return r;
end $$;

create function public.edit_feedback(p_id bigint, p_token uuid, p_content text, p_category text)
returns public.feedback
language plpgsql security definer set search_path = public as $$
declare r public.feedback;
begin
  update public.feedback f set content = p_content, category = p_category, edited_at = now()
  where f.id = p_id and exists (select 1 from public.feedback_owner o where o.feedback_id = p_id and o.token = p_token)
  returning * into r;
  if not found then raise exception 'not_owner'; end if;
  return r;
end $$;

create function public.delete_feedback(p_id bigint, p_token uuid)
returns boolean
language plpgsql security definer set search_path = public as $$
begin
  delete from public.feedback f
  where f.id = p_id and exists (select 1 from public.feedback_owner o where o.feedback_id = p_id and o.token = p_token);
  return found;
end $$;

revoke execute on function public.add_feedback(text,text,text,text,uuid) from public;
revoke execute on function public.edit_feedback(bigint,uuid,text,text) from public;
revoke execute on function public.delete_feedback(bigint,uuid) from public;
grant execute on function public.add_feedback(text,text,text,text,uuid) to anon;
grant execute on function public.edit_feedback(bigint,uuid,text,text) to anon;
grant execute on function public.delete_feedback(bigint,uuid) to anon;

alter publication supabase_realtime add table public.feedback;
alter publication supabase_realtime add table public.rating;
