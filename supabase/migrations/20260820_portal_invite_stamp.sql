-- Track when a Freshpet portal viewer was last sent an invite / walkthrough
-- email, and by whom. Stamped (best-effort, service-role) by apbg-billing's
-- freshpet-portal-users function when an admin sends the invite or a
-- password reset. Applied live to mmkncrsaijexezmhfmiw 2026-08-20.
alter table public.tech_profiles add column if not exists invited_at timestamptz;
alter table public.tech_profiles add column if not exists invited_by text;
