-- Capture when + where each PM was signed.
-- signed_at   : client clock at the moment the tech submitted/signed the PM
-- gps_lat/lng : the tech's GPS at signing (best-effort; may be null if denied)
-- gps_accuracy: reported accuracy in meters (nullable)
alter table public.completed_pms
  add column if not exists signed_at timestamptz,
  add column if not exists gps_lat double precision,
  add column if not exists gps_lng double precision,
  add column if not exists gps_accuracy double precision;

-- Backfill completion time for existing real field completions from the row's
-- insert time (created_at) — a faithful proxy for when the PM was signed.
-- Legacy / previously-completed (imported) rows are left null so the UI keeps
-- showing their service date (created_at there is the import time, not the
-- real service moment). GPS is NOT backfilled: past on-site location is
-- unknown and must not be fabricated.
update public.completed_pms
set signed_at = created_at
where signed_at is null
  and coalesce(prev_comp, false) = false
  and coalesce((form_data->>'legacy')::boolean, false) = false;
