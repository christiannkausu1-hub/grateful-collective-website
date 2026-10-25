-- Grateful Collective trade-payables upgrade (additive; keeps existing records)
ALTER TABLE public.suppliers ADD COLUMN IF NOT EXISTS opening_balance numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE public.suppliers ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;
ALTER TABLE public.trade_payables ADD COLUMN IF NOT EXISTS business_area text NOT NULL DEFAULT 'Administration';
ALTER TABLE public.trade_payables ADD COLUMN IF NOT EXISTS subtotal numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE public.trade_payables ADD COLUMN IF NOT EXISTS discount_amount numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE public.trade_payables ADD COLUMN IF NOT EXISTS tax_amount numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE public.trade_payables ADD COLUMN IF NOT EXISTS credit_terms_days integer NOT NULL DEFAULT 0;
ALTER TABLE public.trade_payables ADD COLUMN IF NOT EXISTS attachment_url text;
UPDATE public.trade_payables SET subtotal=amount WHERE subtotal=0 AND amount>0;
CREATE INDEX IF NOT EXISTS trade_payables_user_due_date_idx ON public.trade_payables(user_id,due_date);
CREATE INDEX IF NOT EXISTS trade_payables_user_supplier_invoice_idx ON public.trade_payables(user_id,supplier_id,invoice_number);
