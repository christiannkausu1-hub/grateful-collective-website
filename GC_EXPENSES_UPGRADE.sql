-- Grateful Collective Expenses upgrade (additive; run after existing migrations)
create table if not exists public.gc_expense_management (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 expense_date date not null default current_date, business_area text not null default 'Administration', category text not null default 'Other',
 description text not null, amount numeric(12,2) not null check(amount>0), supplier text, invoice_reference text, payment_method text not null default 'Cash',
 due_date date, status text not null default 'Pending' check(status in ('Pending','Approved','Rejected','Paid')),
 notes text, attachment_path text, transaction_id text, recurring_id uuid, created_by uuid default auth.uid(), approved_by uuid, approved_at timestamptz, paid_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create unique index if not exists gc_expense_management_invoice_unique on public.gc_expense_management(user_id,lower(invoice_reference)) where invoice_reference is not null and btrim(invoice_reference)<>'';
create index if not exists gc_expense_management_date_idx on public.gc_expense_management(user_id,expense_date desc);
create index if not exists gc_expense_management_status_idx on public.gc_expense_management(user_id,status,due_date);
alter table public.gc_expense_management enable row level security;
drop policy if exists gc_expense_management_select on public.gc_expense_management;
drop policy if exists gc_expense_management_insert on public.gc_expense_management;
drop policy if exists gc_expense_management_update on public.gc_expense_management;
drop policy if exists gc_expense_management_delete on public.gc_expense_management;
create policy gc_expense_management_select on public.gc_expense_management for select using(auth.uid()=user_id);
create policy gc_expense_management_insert on public.gc_expense_management for insert with check(auth.uid()=user_id);
create policy gc_expense_management_update on public.gc_expense_management for update using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy gc_expense_management_delete on public.gc_expense_management for delete using(auth.uid()=user_id);

create table if not exists public.gc_expense_recurring (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 business_area text not null default 'Administration', category text not null default 'Utilities', description text not null,
 amount numeric(12,2) not null check(amount>0), supplier text, invoice_reference_prefix text, payment_method text not null default 'Cash',
 frequency text not null default 'Monthly' check(frequency in ('Weekly','Monthly','Quarterly','Yearly')),
 next_due_date date not null, active boolean not null default true, notes text, created_at timestamptz not null default now()
);
alter table public.gc_expense_recurring enable row level security;
drop policy if exists gc_expense_recurring_all on public.gc_expense_recurring;
create policy gc_expense_recurring_all on public.gc_expense_recurring for all using(auth.uid()=user_id) with check(auth.uid()=user_id);

create table if not exists public.gc_petty_cash (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 entry_date date not null default current_date, entry_type text not null check(entry_type in ('Opening balance','Cash added','Expense','Adjustment')),
 business_area text not null default 'Administration', description text not null, amount numeric(12,2) not null check(amount>0), reference text, created_at timestamptz not null default now()
);
alter table public.gc_petty_cash enable row level security;
drop policy if exists gc_petty_cash_all on public.gc_petty_cash;
create policy gc_petty_cash_all on public.gc_petty_cash for all using(auth.uid()=user_id) with check(auth.uid()=user_id);

create table if not exists public.gc_expense_budgets (
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 business_area text not null, category text not null default 'All categories', period_month date not null,
 budget_amount numeric(12,2) not null check(budget_amount>=0), created_at timestamptz not null default now(),
 unique(user_id,business_area,category,period_month)
);
alter table public.gc_expense_budgets enable row level security;
drop policy if exists gc_expense_budgets_all on public.gc_expense_budgets;
create policy gc_expense_budgets_all on public.gc_expense_budgets for all using(auth.uid()=user_id) with check(auth.uid()=user_id);

-- Audit changes to new expense tables using the existing audit function if it is installed.
do $$ declare t text; begin
 if to_regprocedure('public.gc_capture_audit()') is not null then
  foreach t in array array['gc_expense_management','gc_expense_recurring','gc_petty_cash','gc_expense_budgets'] loop
   execute format('drop trigger if exists gc_audit_trigger on public.%I',t);
   execute format('create trigger gc_audit_trigger after insert or update or delete on public.%I for each row execute function public.gc_capture_audit()',t);
  end loop;
 end if;
end $$;

-- Private bucket for expense receipts and invoice attachments.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('gc-expense-attachments','gc-expense-attachments',false,10485760,array['image/jpeg','image/png','image/webp','application/pdf'])
on conflict(id) do update set public=false,file_size_limit=10485760,allowed_mime_types=array['image/jpeg','image/png','image/webp','application/pdf'];
drop policy if exists gc_expense_files_select_own on storage.objects;
drop policy if exists gc_expense_files_insert_own on storage.objects;
drop policy if exists gc_expense_files_update_own on storage.objects;
drop policy if exists gc_expense_files_delete_own on storage.objects;
create policy gc_expense_files_select_own on storage.objects for select using(bucket_id='gc-expense-attachments' and (storage.foldername(name))[1]=auth.uid()::text);
create policy gc_expense_files_insert_own on storage.objects for insert with check(bucket_id='gc-expense-attachments' and (storage.foldername(name))[1]=auth.uid()::text);
create policy gc_expense_files_update_own on storage.objects for update using(bucket_id='gc-expense-attachments' and (storage.foldername(name))[1]=auth.uid()::text) with check(bucket_id='gc-expense-attachments' and (storage.foldername(name))[1]=auth.uid()::text);
create policy gc_expense_files_delete_own on storage.objects for delete using(bucket_id='gc-expense-attachments' and (storage.foldername(name))[1]=auth.uid()::text);

ALTER TABLE public.gc_expense_management ADD COLUMN IF NOT EXISTS paid_at timestamptz;
