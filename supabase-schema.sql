-- AI Debate Archive: run this once in Supabase SQL Editor.
-- The browser only uses the publishable anon key. Never put service_role here.

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.debate_logs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date text not null check (date ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
  model_a text,
  model_b text,
  participants jsonb not null default '[]'::jsonb,
  judge text,
  turns jsonb not null default '[]'::jsonb,
  critique text not null default '',
  memo text not null default '',
  raw text not null default '',
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;
alter table public.debate_logs enable row level security;

drop policy if exists "Public can read debate logs" on public.debate_logs;
create policy "Public can read debate logs"
  on public.debate_logs for select
  to anon, authenticated
  using (true);

drop policy if exists "Admins can insert debate logs" on public.debate_logs;
create policy "Admins can insert debate logs"
  on public.debate_logs for insert
  to authenticated
  with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

drop policy if exists "Admins can update debate logs" on public.debate_logs;
create policy "Admins can update debate logs"
  on public.debate_logs for update
  to authenticated
  using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

drop policy if exists "Admins can delete debate logs" on public.debate_logs;
create policy "Admins can delete debate logs"
  on public.debate_logs for delete
  to authenticated
  using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Do not expose admin_users to the browser. Add the already-created admin account
-- from the Supabase SQL editor after checking its UUID in Authentication > Users:
-- insert into public.admin_users (user_id) values ('REPLACE_WITH_ADMIN_USER_UUID');
