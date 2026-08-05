-- Issue reports emailed to Freshpet.
--
-- The admin console's "Report Issues" tab emails Freshpet a list of extra
-- coolers (added assets) and coolers with problems, with each PM's photos and
-- signed report PDF attached (apbg-billing freshpet-issue-report function).
-- Stamp each included PM so the list shows what was already sent and when.
--
-- Applied to Supabase project mmkncrsaijexezmhfmiw on 2026-07-23.

alter table public.completed_pms
  add column if not exists issue_emailed_at timestamptz,
  add column if not exists issue_emailed_to text;

comment on column public.completed_pms.issue_emailed_at is 'last time this PM was included in an issue-report email to Freshpet';
comment on column public.completed_pms.issue_emailed_to is 'recipients of the last issue-report email that included this PM';
