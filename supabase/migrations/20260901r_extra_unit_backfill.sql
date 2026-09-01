-- DATA MIGRATION, run once on 2026-09-01. Recorded here because it created
-- customer-visible asset records by hand and the reasoning has to be auditable.
--
-- Nine visits reported, in the comments box, a cooler on site that was not on
-- Freshpet's asset list. Nothing acted on any of them -- four were not even
-- flagged for review -- so none of those units had a record. The code fix is in
-- index.html (a note now raises needs_review); this is the cleanup.
--
-- Checked each against the asset list first, and TWO were already true:
--   #568 Save Mart #95   -- second unit 10874883 came across on the June import
--                           and has its own PM. Nothing created.
--   #578 Walmart US #3046 -- the tech added unit 11200211 himself the same day.
--                           Nothing created.
-- Creating records for those would have put duplicates on the customer's books.
--
-- The other seven get a record. Not guessed: manufacturer/model stay BLANK
-- rather than copied from the unit beside them, the serial is a visibly-fake
-- NO-SERIAL-<date>-PM<id> placeholder with no_serial set (nobody ever read the
-- plate), and pm_fee is 0 because the unit has never had a PM and an invented
-- fee flows into billing. They are deliberately NOT added to any route -- that
-- schedules billable work and is an operator's decision, not a backfill's.
insert into public.assets
  (store, address, city, state, zip, phone, manufacturer, model, serial, warranty,
   no_serial, pm_fee, lat, lng, active, source, reported, added_by, added_at, found_on_pm_id)
select
  a.store, a.address, a.city, a.state, a.zip, coalesce(a.phone,''),
  '', '',
  'NO-SERIAL-' || to_char(p.pm_date,'YYYYMMDD') || '-PM' || p.id,
  'OUT', true, 0, a.lat, a.lng, true, 'field', false,
  coalesce(p.tech_name,'field report') || ' (from report #' || p.id || ')',
  (p.pm_date::timestamptz + interval '12 hours'),
  p.id
from (values (431),(483),(493),(494),(506),(582),(608)) as src(pm_id)
join public.completed_pms p on p.id = src.pm_id
join public.assets a on a.id = p.asset_id
where not exists (select 1 from public.assets x where x.found_on_pm_id = p.id and x.source = 'field');

-- The open item MOVES to the asset (unreported, tracked on the portal's Asset
-- list), so the PM's own review flag clears. One thing, one place.
update public.completed_pms p
   set needs_review = false,
       form_data = jsonb_set(p.form_data, '{audit_note}',
         to_jsonb(trim(coalesce(p.form_data->>'audit_note','') || ' ' ||
           'NOTE ACTIONED 2026-09-01: the technician reported an extra unit at this store that was not on the '
           || 'asset list. An asset record has been created for it (' || a.serial || '), filed as field-found with '
           || 'no serial plate recorded. It is now on the Freshpet portal''s Asset list until Freshpet adds it to '
           || 'their books. The serial still needs to be read off the unit on the next visit.'))),
       modified_at = now(),
       modified_by = 'asset-list backfill (extra unit reported in the visit note)'
  from public.assets a
 where a.found_on_pm_id = p.id and a.source = 'field' and a.no_serial
   and p.id in (431,483,493,494,506,582,608);
