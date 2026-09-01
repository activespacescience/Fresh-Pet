-- A queryable audit outcome on each PM report.
-- The 2026-08 photo-integrity audit recorded its findings in form_data.audit_note, which is
-- human-readable but not filterable — so the reports that need action were invisible in the
-- console. This makes the outcome a first-class, indexable state.
-- Applied live 2026-08-28 via the Supabase MCP.
alter table public.completed_pms
  add column if not exists audit_flag text
  check (audit_flag in ('needs_plate_photo','asset_list_confirm','credit_review','resolved'));

comment on column public.completed_pms.audit_flag is
  'Outcome of the photo-integrity audit. needs_plate_photo = no photograph of this unit''s own serial plate exists, a re-visit is required. asset_list_confirm = the plate photographed reads a serial not on the Freshpet asset list. credit_review = duplicate or otherwise not billable. resolved = closed out.';

create index if not exists completed_pms_audit_flag_idx
  on public.completed_pms (audit_flag) where audit_flag is not null;

-- Population of the flag for the 2026-08 audit was applied as data, not schema:
--   needs_plate_photo  166 reports (101 June, 49 July, 16 August)
--   asset_list_confirm  29 reports
--   credit_review        2 reports (#485 Kelley's duplicate, #566 duplicate asset)
