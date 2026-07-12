-- Capture when + where each PM was signed.
-- signed_at   : client clock at the moment the tech submitted/signed the PM
-- gps_lat/lng : the tech's GPS at signing (best-effort; may be null if denied)
-- gps_accuracy: reported accuracy in meters (nullable)
alter table public.completed_pms
  add column if not exists signed_at timestamptz,
  add column if not exists gps_lat double precision,
  add column if not exists gps_lng double precision,
  add column if not exists gps_accuracy double precision;

-- Backfill completion time for existing real field completions.
-- Preferred source: the on-device timestamp embedded in the report PDF's
-- filename (`..._<Date.now()ms>.pdf`, captured the instant the PDF was
-- generated on-site) — this is the PDF-creation time. Fall back to the row's
-- insert time (created_at) when the filename has no parseable stamp.
-- Legacy / previously-completed (imported) rows are left null so the UI keeps
-- showing their service date (their created_at is the import time, not a real
-- visit). GPS is NOT backfilled: past on-site location was never captured
-- (report PDFs are text-only; photos were canvas-re-encoded, stripping EXIF)
-- and must not be fabricated.
update public.completed_pms
set signed_at = coalesce(
  to_timestamp(nullif(substring(pdf_path from '_(\d{13})\.pdf$'), '')::bigint / 1000.0),
  created_at)
where signed_at is null
  and coalesce(prev_comp, false) = false
  and coalesce((form_data->>'legacy')::boolean, false) = false;
