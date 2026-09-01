-- RE-VISIT controls: flag a completed PM whose documentation cannot be trusted,
-- disconnect its bad data, and drive a redo of the whole stop.
-- Applied live 2026-08-28 via the Supabase MCP.
alter table public.completed_pms
  add column if not exists revisit_requested_at  timestamptz,
  add column if not exists revisit_requested_by  text,
  add column if not exists revisit_reason        text,
  add column if not exists revisit_done_at       timestamptz,
  add column if not exists revisit_done_pm_id    bigint;

comment on column public.completed_pms.revisit_requested_at is
  'Set when this PM is flagged for a re-visit. Its photo evidence has been disconnected (see form_data.revisit_cleared_photos) and the stop must be redone.';
comment on column public.completed_pms.revisit_reason is
  'Why the re-visit was ordered, e.g. no_plate_photo, wrong_unit_photo, unverifiable.';
comment on column public.completed_pms.revisit_done_pm_id is
  'completed_pms.id of the replacement PM produced by the re-visit.';

create index if not exists completed_pms_revisit_open_idx
  on public.completed_pms (revisit_requested_at)
  where revisit_requested_at is not null and revisit_done_at is null;

create or replace view public.v_revisits_open as
select c.id as pm_id, c.asset_id, c.store, c.serial,
       c.pm_date as original_pm_date, c.tech_name as original_tech,
       c.revisit_requested_at, c.revisit_requested_by, c.revisit_reason,
       c.invoice_doc_number,
       a.address, a.city, a.state, a.zip, a.active as asset_active
from public.completed_pms c
left join public.assets a on a.id = c.asset_id
where c.revisit_requested_at is not null and c.revisit_done_at is null;

grant select on public.v_revisits_open to authenticated;
