-- DATA MIGRATION, run once on 2026-09-02. Recorded because it created 24
-- customer-visible asset records and the test applied has to be auditable.
--
-- Sky: "If they have serial number plates only then keep them as true new
-- coolers." A plate we photographed AND read is a cooler that exists. The
-- reason these were held as candidates rather than assets was the risk that the
-- photograph belonged to another store's report -- which is the exact defect
-- this whole incident is about, and which happened 43 times.
--
-- So promotion is gated on the photograph being one we STAND BEHIND. A plate
-- read off a report that is under re-shoot is evidence we have already told
-- Freshpet not to rely on; promoting it would contradict the hold on that very
-- report. Verified before running: 0 of the 24 came from a report under
-- re-shoot, so all 24 passed.
--
-- Not guessed, same rules as the 2026-09-01 backfill: make and model stay BLANK
-- rather than copied from the unit beside them, pm_fee is 0 because the unit
-- has never had a PM and an invented fee flows into billing, and none are put
-- on a route -- that schedules billable work and is an operator's decision.
-- added_by records the report the plate was photographed on.
with promote as (
  select c.id as cand_id, trim(c.serial_read) as new_serial, c.source_pm_id,
         a.store as a_store, a.address as a_address, a.city as a_city, a.state as a_state,
         a.zip as a_zip, a.phone as a_phone, a.lat as a_lat, a.lng as a_lng
    from public.asset_list_candidates c
    join public.completed_pms p on p.id = c.source_pm_id
    join public.assets a on a.id = p.asset_id
   where c.status = 'open'
     and c.serial_read is not null and c.serial_read <> ''
     -- never re-create a serial the list already carries
     and not exists (select 1 from public.assets x where upper(trim(x.serial)) = upper(trim(c.serial_read)))
     -- and never promote a read off documentation we have disclaimed
     and not exists (select 1 from public.completed_pms r
                      where r.id = c.source_pm_id
                        and r.revisit_requested_at is not null and r.revisit_done_at is null)
),
ins as (
  insert into public.assets
    (store,address,city,state,zip,phone,manufacturer,model,serial,warranty,
     no_serial,pm_fee,lat,lng,active,source,reported,added_by,added_at,found_on_pm_id)
  select pr.a_store, pr.a_address, pr.a_city, pr.a_state, pr.a_zip, coalesce(pr.a_phone,''),
         '', '', pr.new_serial, 'OUT',
         false, 0, pr.a_lat, pr.a_lng, true, 'field', false,
         'plate photograph on report #' || pr.source_pm_id, now(), pr.source_pm_id
  from promote pr
  returning id, serial, found_on_pm_id
)
update public.asset_list_candidates c
   set status = 'confirmed', asset_id = i.id,
       resolution = 'Kept as a true new cooler 2026-09-02: the plate was photographed and read, and that photograph sits on a report we stand behind (not one under re-shoot). Filed as a field-found unit with its serial and shown to Freshpet on the Asset list.',
       resolved_at = now(), resolved_by = 'skypace@brixbev.com'
  from ins i
 where c.source_pm_id = i.found_on_pm_id
   and upper(trim(c.serial_read)) = upper(trim(i.serial))
   and c.status = 'open';
