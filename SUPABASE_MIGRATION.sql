ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS pupil_type text NOT NULL DEFAULT 'NOT A NEWCOMER';
ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS requirements_checklist jsonb NOT NULL DEFAULT '[]'::jsonb;
