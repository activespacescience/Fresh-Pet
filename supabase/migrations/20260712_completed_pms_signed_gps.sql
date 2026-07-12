-- Capture when + where each PM was signed.
-- signed_at   : client clock at the moment the tech submitted/signed the PM
-- gps_lat/lng : the tech's GPS at signing (best-effort; may be null if denied)
-- gps_accuracy: reported accuracy in meters (nullable)
alter table public.completed_pms
  add column if not exists signed_at timestamptz,
  add column if not exists gps_lat double precision,
  add column if not exists gps_lng double precision,
  add column if not exists gps_accuracy double precision;
