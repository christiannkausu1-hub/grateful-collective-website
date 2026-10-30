-- Additive rental fix for THE GRATEFUL COLLECTIVE. Safe to run more than once.
-- Preserves existing rental units and rent payments.
ALTER TABLE public.rental_units ADD COLUMN IF NOT EXISTS rent_start_date date;
ALTER TABLE public.rental_units ADD COLUMN IF NOT EXISTS due_day integer;
ALTER TABLE public.rental_payments ADD COLUMN IF NOT EXISTS period_start date;
ALTER TABLE public.rental_payments ADD COLUMN IF NOT EXISTS method text;
ALTER TABLE public.rental_payments ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE public.rental_payments ADD COLUMN IF NOT EXISTS transaction_id uuid;

-- Backfill start dates only where missing, using created_at when available.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='rental_units' AND column_name='created_at'
  ) THEN
    EXECUTE 'UPDATE public.rental_units SET rent_start_date = created_at::date WHERE rent_start_date IS NULL';
    EXECUTE 'UPDATE public.rental_units SET due_day = EXTRACT(DAY FROM COALESCE(rent_start_date, created_at::date))::integer WHERE due_day IS NULL';
  ELSE
    UPDATE public.rental_units SET rent_start_date = CURRENT_DATE WHERE rent_start_date IS NULL;
    UPDATE public.rental_units SET due_day = EXTRACT(DAY FROM rent_start_date)::integer WHERE due_day IS NULL;
  END IF;
END $$;

UPDATE public.rental_units
SET due_day = EXTRACT(DAY FROM rent_start_date)::integer
WHERE due_day IS NULL AND rent_start_date IS NOT NULL;

-- Keep rental data private to its owner. Existing policies are left untouched.
ALTER TABLE public.rental_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rental_payments ENABLE ROW LEVEL SECURITY;
