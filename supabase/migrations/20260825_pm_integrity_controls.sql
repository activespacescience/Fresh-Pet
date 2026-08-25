-- PM report integrity controls — corrective action for the Freshpet review of
-- invoice #172825 (43 of 196 reports carried photos byte-identical to another
-- report's photos; 5 reports for closed/unit-less stores were filed through
-- the only form the app offered — a full PM checklist).
--
-- ⚠ NOT applied to the live project yet. Apply via the Supabase MCP to
-- project mmkncrsaijexezmhfmiw BEFORE merging the companion app change —
-- the field app inserts these columns on every submit.
--
-- photo_hashes : SHA-256 of each attached photo's dataURL, same order as
--                photo_paths. The field app refuses to attach an image whose
--                hash already backs any other report (the duplicate-photo
--                guard). Historical rows stay null — the guard only sees
--                hashes written from this change forward; the investigation's
--                hash table (investigation/) covers the historical batch.
-- visit_type   : 'pm' (a real preventive-maintenance service) or 'exception'
--                (the tech reached the site but could not service the unit —
--                store closed, unit missing, no access). Exception visits are
--                excluded from PM invoicing by the admin console and by
--                apbg-billing's freshpet-invoice function.
-- exception_reason : store_closed | unit_missing | no_access | other.
alter table public.completed_pms
  add column if not exists photo_hashes text[],
  add column if not exists visit_type text not null default 'pm',
  add column if not exists exception_reason text;

alter table public.completed_pms
  drop constraint if exists completed_pms_visit_type_check;
alter table public.completed_pms
  add constraint completed_pms_visit_type_check
  check (visit_type in ('pm', 'exception'));
