-- Run after JSON restore that upserts explicit IDs. Safe to re-run.
-- SECURITY DEFINER is required for setval; execute is restricted to authenticated administrators.
create or replace function public.gc_sync_identity_sequences()
returns integer language plpgsql security definer set search_path=public,pg_temp as $$
declare t text; seq_name text; max_id bigint; synced integer:=0;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if to_regclass('public.gc_user_roles') is null then raise exception 'Role table public.gc_user_roles is missing; cannot verify administrator access'; end if;
 if not exists(select 1 from public.gc_user_roles r where r.user_id=auth.uid() and r.role='administrator') then raise exception 'Administrator role required'; end if;
 foreach t in array array[
  'transactions','rental_units','rental_payments','suppliers','trade_payables','trade_payable_payments',
  'workers','payroll_records','pupils','lunch_payments','school_tests','test_payments','school_grade_fees',
  'gc_transfers','gc_reconciliation','gc_shop_products','gc_shop_movements','gc_shop_customers',
  'gc_shop_sales','gc_shop_sale_items','gc_shop_customer_payments','gc_shop_refunds','gc_shop_product_cost_history','gc_expense_management',
  'gc_expense_recurring','gc_petty_cash','gc_expense_budgets','gc_fixed_assets',
  'gc_payroll_advances','gc_payroll_leave','gc_payroll_attendance','gc_teacher_napsa_returns','gc_audit_log'
 ] loop
  begin
   seq_name:=null;
   if to_regclass(format('public.%I',t)) is not null then seq_name:=pg_get_serial_sequence(format('public.%I',t),'id'); end if;
   if seq_name is not null then
    execute format('select max(id)::bigint from public.%I',t) into max_id;
    perform setval(seq_name::regclass,coalesce(max_id,1),max_id is not null);
    synced:=synced+1;
   end if;
  exception when others then
   raise warning 'Identity sequence sync failed for table %: %',t,sqlerrm;
  end;
 end loop;
 return synced;
end; $$;
revoke all on function public.gc_sync_identity_sequences() from public;
grant execute on function public.gc_sync_identity_sequences() to authenticated;
