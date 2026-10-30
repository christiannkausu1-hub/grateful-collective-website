-- Teacher NAPSA return register. Contribution rates are configurable per return;
-- confirm statutory rates/caps with NAPSA before preparing a statutory submission.
create table if not exists public.gc_teacher_napsa_returns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  worker_id bigint not null references public.workers(id) on delete cascade,
  account_number text not null,
  year integer not null check (year between 2000 and 2100),
  month integer not null check (month between 1 and 12),
  ssno text,
  nrc_no text,
  surname text not null,
  firstname text not null,
  other_name text,
  date_of_birth date,
  gross_wage numeric(12,2) not null default 0 check (gross_wage >= 0),
  employer_rate numeric(5,2) not null default 5 check (employer_rate between 0 and 100),
  employee_rate numeric(5,2) not null default 5 check (employee_rate between 0 and 100),
  employer_share numeric(12,2) not null default 0 check (employer_share >= 0),
  employee_share numeric(12,2) not null default 0 check (employee_share >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, worker_id, year, month)
);

-- Safe additive changes for installations created by earlier package versions.
alter table public.gc_teacher_napsa_returns alter column account_number drop default;
alter table public.gc_teacher_napsa_returns add column if not exists employer_rate numeric(5,2) not null default 5;
alter table public.gc_teacher_napsa_returns add column if not exists employee_rate numeric(5,2) not null default 5;
do $$ begin
  if not exists (select 1 from pg_constraint where conname='gc_teacher_napsa_employer_rate_check' and conrelid='public.gc_teacher_napsa_returns'::regclass) then
    alter table public.gc_teacher_napsa_returns add constraint gc_teacher_napsa_employer_rate_check check (employer_rate between 0 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conname='gc_teacher_napsa_employee_rate_check' and conrelid='public.gc_teacher_napsa_returns'::regclass) then
    alter table public.gc_teacher_napsa_returns add constraint gc_teacher_napsa_employee_rate_check check (employee_rate between 0 and 100);
  end if;
end $$;
create index if not exists gc_teacher_napsa_returns_user_period_idx on public.gc_teacher_napsa_returns(user_id, year desc, month desc);
alter table public.gc_teacher_napsa_returns enable row level security;
drop policy if exists gc_teacher_napsa_returns_select_own on public.gc_teacher_napsa_returns;
drop policy if exists gc_teacher_napsa_returns_insert_own on public.gc_teacher_napsa_returns;
drop policy if exists gc_teacher_napsa_returns_update_own on public.gc_teacher_napsa_returns;
drop policy if exists gc_teacher_napsa_returns_delete_own on public.gc_teacher_napsa_returns;
create policy gc_teacher_napsa_returns_select_own on public.gc_teacher_napsa_returns for select to authenticated
using (user_id = auth.uid() and exists (select 1 from public.gc_user_roles r where r.user_id=auth.uid() and r.role='administrator'));
create policy gc_teacher_napsa_returns_insert_own on public.gc_teacher_napsa_returns for insert to authenticated
with check (user_id = auth.uid()
  and exists (select 1 from public.gc_user_roles r where r.user_id=auth.uid() and r.role='administrator')
  and exists (select 1 from public.workers w where w.id=worker_id and w.user_id=auth.uid() and lower(trim(coalesce(w.job_title,''))) in ('teacher','owner')));
create policy gc_teacher_napsa_returns_update_own on public.gc_teacher_napsa_returns for update to authenticated
using (user_id = auth.uid() and exists (select 1 from public.gc_user_roles r where r.user_id=auth.uid() and r.role='administrator'))
with check (user_id = auth.uid()
  and exists (select 1 from public.gc_user_roles r where r.user_id=auth.uid() and r.role='administrator')
  and exists (select 1 from public.workers w where w.id=worker_id and w.user_id=auth.uid() and lower(trim(coalesce(w.job_title,''))) in ('teacher','owner')));
create policy gc_teacher_napsa_returns_delete_own on public.gc_teacher_napsa_returns for delete to authenticated
using (user_id = auth.uid() and exists (select 1 from public.gc_user_roles r where r.user_id=auth.uid() and r.role='administrator'));
