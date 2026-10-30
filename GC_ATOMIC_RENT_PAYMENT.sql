-- Atomic rent-payment recording for THE GRATEFUL COLLECTIVE.
-- Run after the existing rental and transaction table migrations.
create or replace function public.gc_record_rent_payment(
  p_rental_unit_id uuid, p_period_start date, p_payment_date date,
  p_amount numeric, p_method text, p_notes text default null
) returns uuid
language plpgsql security invoker set search_path = public as $$
declare
  v_user_id uuid := auth.uid();
  v_payment_id uuid;
  v_transaction_id uuid;
  v_tenant_name text;
  v_building text;
begin
  if v_user_id is null then raise exception 'Authentication required'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Rent payment amount must be greater than zero'; end if;
  if p_period_start is null or p_payment_date is null then raise exception 'Rental period and payment date are required'; end if;
  select tenant_name, building into v_tenant_name, v_building
    from public.rental_units where id=p_rental_unit_id and user_id=v_user_id for share;
  if not found then raise exception 'Rental unit not found or access denied'; end if;
  insert into public.rental_payments(user_id,rental_unit_id,period_start,payment_date,amount,method,notes,transaction_id)
  values(v_user_id,p_rental_unit_id,p_period_start,p_payment_date,p_amount,p_method,p_notes,null)
  returning id into v_payment_id;
  insert into public.transactions(user_id,date,type,area,category,description,amount,method,notes)
  values(v_user_id,p_payment_date,'Income','Rent','Rent received',
    format('Rent — %s (%s) — period %s',v_tenant_name,v_building,p_period_start),p_amount,p_method,
    coalesce(nullif(trim(p_notes),''),'Rental period start: '||p_period_start))
  returning id into v_transaction_id;
  update public.rental_payments set transaction_id=v_transaction_id
   where id=v_payment_id and user_id=v_user_id;
  return v_payment_id;
end; $$;
revoke all on function public.gc_record_rent_payment(uuid,date,date,numeric,text,text) from public;
grant execute on function public.gc_record_rent_payment(uuid,date,date,numeric,text,text) to authenticated;
