THE GRATEFUL COLLECTIVE — GC INSTALLABLE WEB APP

FILES
- index.html: website/app
- manifest.webmanifest: installable app metadata
- service-worker.js: offline shell and update checking
- icons/: GC app icons

DEPLOY
Upload the contents of this folder to the ROOT of your existing Cloudflare Pages project and deploy. Keep the same Cloudflare Pages URL so the installed app can receive site updates.

PUPIL REQUIREMENTS DATABASE CHANGE
The new optional Requirements field is stored in public.pupils.requirements. Run this once in Supabase SQL Editor if that column does not already exist:

ALTER TABLE public.pupils ADD COLUMN IF NOT EXISTS requirements text;

APP INSTALL
Open the deployed Cloudflare Pages URL in Chrome on Android, open the browser menu, and choose Install app or Add to Home screen. This is a PWA, not a native APK.

SECURITY
Do not add a Supabase service_role key to this app. The existing public/publishable key is intended for client-side use with correctly configured Supabase RLS policies.
