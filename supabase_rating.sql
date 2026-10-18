-- 교육 평가(5점 척도) 테이블 추가. 기존 supabase.sql을 실행한 뒤 SQL Editor에 이 파일 전체를 붙여넣고 Run
-- 평가에는 부서만 저장하고 이름·닉네임은 저장하지 않음
create table if not exists public.rating (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  dept text not null check (char_length(dept) between 1 and 30),
  q1 smallint not null check (q1 between 1 and 5),
  q2 smallint not null check (q2 between 1 and 5)
);

alter table public.rating enable row level security;

drop policy if exists "anyone can read rating" on public.rating;
create policy "anyone can read rating" on public.rating for select to anon using (true);

drop policy if exists "anyone can insert rating" on public.rating;
create policy "anyone can insert rating" on public.rating for insert to anon with check (true);

alter publication supabase_realtime add table public.rating;
