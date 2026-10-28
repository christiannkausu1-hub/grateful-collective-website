-- Separate editable NAPSA return register for workers whose job_title is exactly 'Teacher'.
create table if not exists public.gc_teacher_napsa_returns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  worker_id bigint not null references public.workers(id) on delete cascade,
  account_number text not null default '100000',
  year integer not null check (year between 2000 and 2100),
  month integer not null check (month between 1 and 12),
  ssno text,
  nrc_no text,
  surname text not null,
  firstname text not null,
  other_name text,
  date_of_birth date,
  gross_wage numeric(12,2) not null default 0 check (gross_wage >= 0),
  employer_share numeric(12,2) not null default 0 check (employer_share >= 0),
  employee_share numeric(12,2) not null default 0 check (employee_share >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, worker_id, year, month)
);
create index if not exists gc_teacher_napsa_returns_user_period_idx on public.gc_teacher_napsa_returns(user_id, year desc, month desc);
alter table public.gc_teacher_napsa_returns enable row level security;
drop policy if exists gc_teacher_napsa_returns_select_own on public.gc_teacher_napsa_returns;
drop policy if exists gc_teacher_napsa_returns_insert_own on public.gc_teacher_napsa_returns;
drop policy if exists gc_teacher_napsa_returns_update_own on public.gc_teacher_napsa_returns;
drop policy if exists gc_teacher_napsa_returns_delete_own on public.gc_teacher_napsa_returns;
create policy gc_teacher_napsa_returns_select_own on public.gc_teacher_napsa_returns for select to authenticated using (user_id = auth.uid());
create policy gc_teacher_napsa_returns_insert_own on public.gc_teacher_napsa_returns for insert to authenticated with check (user_id = auth.uid());
create policy gc_teacher_napsa_returns_update_own on public.gc_teacher_napsa_returns for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy gc_teacher_napsa_returns_delete_own on public.gc_teacher_napsa_returns for delete to authenticated using (user_id = auth.uid());
