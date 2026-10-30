-- Atomic shop operations. Run after GC_ENHANCEMENTS.sql and GC_SHOPS_UPGRADE.sql.
-- SECURITY INVOKER preserves the caller's table grants and RLS policies.
create or replace function public.gc_record_shop_sale(
 p_product_id bigint, p_quantity numeric, p_unit_price numeric, p_discount numeric,
 p_amount_paid numeric, p_payment_method text, p_sale_date date,
 p_customer_name text default null, p_customer_phone text default null, p_notes text default null,
 p_receipt_number text default null
) returns bigint language plpgsql security invoker set search_path=public as $$
declare v_uid uuid:=auth.uid(); v_product public.gc_shop_products%rowtype; v_customer_id bigint; v_sale_id bigint;
 v_subtotal numeric(12,2); v_total numeric(12,2); v_customer_name text:=nullif(trim(p_customer_name),'');
begin
 if v_uid is null then raise exception 'Authentication required'; end if;
 if p_quantity is null or p_quantity<=0 or p_unit_price is null or p_unit_price<0 or p_discount is null or p_discount<0 or p_amount_paid is null or p_amount_paid<0 then raise exception 'Invalid sale values'; end if;
 select * into v_product from public.gc_shop_products where id=p_product_id and user_id=v_uid for update;
 if not found then raise exception 'Product not found or access denied'; end if;
 if p_quantity>v_product.quantity then raise exception 'Insufficient stock; available quantity is %',v_product.quantity; end if;
 v_subtotal:=round(p_quantity*p_unit_price,2); v_total:=v_subtotal-p_discount;
 if p_discount>v_subtotal or p_amount_paid>v_total then raise exception 'Discount or amount received exceeds sale total'; end if;
 if upper(coalesce(p_payment_method,''))='CREDIT' and (v_customer_name is null or nullif(trim(p_customer_phone),'') is null) then raise exception 'Customer name and phone are required for credit sales'; end if;
 if v_customer_name is not null then
  select id into v_customer_id from public.gc_shop_customers where user_id=v_uid and lower(customer_name)=lower(v_customer_name) and coalesce(phone,'')=coalesce(nullif(trim(p_customer_phone),''),'') order by id limit 1;
  if v_customer_id is null then insert into public.gc_shop_customers(user_id,customer_name,phone) values(v_uid,v_customer_name,nullif(trim(p_customer_phone),'')) returning id into v_customer_id; end if;
 end if;
 insert into public.gc_shop_sales(user_id,receipt_number,shop,customer_id,customer_name,customer_phone,sale_date,subtotal,discount,total,amount_paid,payment_method,status,notes)
 values(v_uid,coalesce(nullif(trim(p_receipt_number),''),'GC-'||upper(left(regexp_replace(v_product.shop,'[^A-Z]','','g'),3))||'-'||substr(md5(random()::text||clock_timestamp()::text),1,8)),v_product.shop,v_customer_id,coalesce(v_customer_name,'Walk-in customer'),nullif(trim(p_customer_phone),''),p_sale_date,v_subtotal,p_discount,v_total,p_amount_paid,p_payment_method,'COMPLETED',nullif(trim(p_notes),'')) returning id into v_sale_id;
 insert into public.gc_shop_sale_items(user_id,sale_id,product_id,product_name,quantity,unit_price,unit_cost,line_total)
 values(v_uid,v_sale_id,v_product.id,v_product.product_name,p_quantity,p_unit_price,v_product.unit_cost,v_total);
 update public.gc_shop_products set quantity=quantity-p_quantity,updated_at=now() where id=v_product.id and user_id=v_uid;
 insert into public.gc_shop_movements(user_id,product_id,shop,movement_date,movement_type,quantity,unit_price,amount,description)
 values(v_uid,v_product.id,v_product.shop,p_sale_date,'SALE',p_quantity,p_unit_price,v_total,'Receipt '||(select receipt_number from public.gc_shop_sales where id=v_sale_id)||'; '||p_payment_method||'; discount '||p_discount);
 if p_amount_paid>0 then
  insert into public.transactions(user_id,date,type,area,category,description,amount,method,notes)
  values(v_uid,p_sale_date,'Income','Shop',v_product.shop||' | Sales','Shop sale '||(select receipt_number from public.gc_shop_sales where id=v_sale_id)||' — '||v_product.product_name,p_amount_paid,case when p_payment_method='Credit' then 'Other' else p_payment_method end,'Shop sale total '||v_total||'; discount '||p_discount||'; amount received '||p_amount_paid);
 end if;
 return v_sale_id;
end; $$;

create or replace function public.gc_record_shop_credit_payment(
 p_sale_id bigint,p_payment_date date,p_amount numeric,p_payment_method text,p_notes text default null
) returns bigint language plpgsql security invoker set search_path=public as $$
declare v_uid uuid:=auth.uid(); v_sale public.gc_shop_sales%rowtype; v_payment_id bigint;
begin
 if v_uid is null then raise exception 'Authentication required'; end if;
 if p_amount is null or p_amount<=0 or p_payment_date is null then raise exception 'Enter a valid payment date and amount'; end if;
 select * into v_sale from public.gc_shop_sales where id=p_sale_id and user_id=v_uid for update;
 if not found or v_sale.status<>'COMPLETED' then raise exception 'Open sale not found or access denied'; end if;
 if p_amount>v_sale.total-v_sale.amount_paid then raise exception 'Payment exceeds outstanding balance'; end if;
 insert into public.gc_shop_customer_payments(user_id,sale_id,customer_id,payment_date,amount,payment_method,notes)
 values(v_uid,v_sale.id,v_sale.customer_id,p_payment_date,p_amount,p_payment_method,nullif(trim(p_notes),'')) returning id into v_payment_id;
 update public.gc_shop_sales set amount_paid=amount_paid+p_amount,payment_method='Part-paid / credit' where id=v_sale.id and user_id=v_uid;
 insert into public.transactions(user_id,date,type,area,category,description,amount,method,notes)
 values(v_uid,p_payment_date,'Income','Shop',v_sale.shop||' | Credit sale payment','Credit payment for '||v_sale.receipt_number||' — '||coalesce(v_sale.customer_name,'Customer'),p_amount,p_payment_method,nullif(trim(p_notes),''));
 return v_payment_id;
end; $$;

create or replace function public.gc_cancel_shop_sale(p_sale_id bigint,p_refund_date date default current_date)
returns boolean language plpgsql security invoker set search_path=public as $$
declare v_uid uuid:=auth.uid(); v_sale public.gc_shop_sales%rowtype; v_item record;
begin
 if v_uid is null then raise exception 'Authentication required'; end if;
 select * into v_sale from public.gc_shop_sales where id=p_sale_id and user_id=v_uid for update;
 if not found or v_sale.status<>'COMPLETED' then raise exception 'Completed sale not found or already cancelled'; end if;
 for v_item in select * from public.gc_shop_sale_items where sale_id=v_sale.id and user_id=v_uid loop
  if v_item.product_id is not null then
   update public.gc_shop_products set quantity=quantity+v_item.quantity,updated_at=now() where id=v_item.product_id and user_id=v_uid;
   if not found then raise exception 'Could not restore stock for product %',v_item.product_id; end if;
   update public.gc_shop_movements set movement_type='CANCELLED',description='Cancelled receipt '||v_sale.receipt_number where user_id=v_uid and product_id=v_item.product_id and movement_type='SALE' and description like '%'||v_sale.receipt_number||'%';
  end if;
 end loop;
 update public.gc_shop_sales set status='CANCELLED' where id=v_sale.id and user_id=v_uid;
 if v_sale.amount_paid>0 then
  insert into public.transactions(user_id,date,type,area,category,description,amount,method,notes)
  values(v_uid,p_refund_date,'Expense','Shop',v_sale.shop||' | Refund','Refund for cancelled receipt '||v_sale.receipt_number,v_sale.amount_paid,case when v_sale.payment_method='Part-paid / credit' then 'Cash' else v_sale.payment_method end,'Refund entered when cancelling a sale; verify actual payment channel.');
 end if;
 return true;
end; $$;

revoke all on function public.gc_record_shop_sale(bigint,numeric,numeric,numeric,numeric,text,date,text,text,text,text) from public;
revoke all on function public.gc_record_shop_credit_payment(bigint,date,numeric,text,text) from public;
revoke all on function public.gc_cancel_shop_sale(bigint,date) from public;
grant execute on function public.gc_record_shop_sale(bigint,numeric,numeric,numeric,numeric,text,date,text,text,text,text) to authenticated;
grant execute on function public.gc_record_shop_credit_payment(bigint,date,numeric,text,text) to authenticated;
grant execute on function public.gc_cancel_shop_sale(bigint,date) to authenticated;
