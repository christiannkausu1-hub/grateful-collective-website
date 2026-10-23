-- Run once in Supabase SQL Editor
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS requirements text;
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS requirements_checklist jsonb NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS pupil_type text NOT NULL DEFAULT 'NOT A NEWCOMER';
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS amount_paid numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS enrollment_date date;
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS term text;
