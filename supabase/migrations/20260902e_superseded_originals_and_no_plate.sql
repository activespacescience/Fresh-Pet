-- Applied live 2026-09-02.
--
-- Two loops found by checking Mike's Oceana Market re-shoot (report 681, the
-- FIRST completed re-shoot in the system) — both latent until that visit landed.
--
-- 1. A SUPERSEDED ORIGINAL CAME BACK ONTO THE AUDIT BOARD.
--    fn_pm_nightly_audit skipped a report while its re-shoot was OUTSTANDING
--    ("awaiting_reshoot"), and only while it was outstanding. The moment the
--    re-shoot landed, the original re-entered every documentation check — and
--    it can never pass any of them again: its photographs were deliberately
--    disconnected when the re-visit was ordered, and the reason it was sent
--    back out is the reason it fails. Report 662 duly came back red twice over
--    (photos_none, signature_missing) plus an amber, minutes after the visit
--    that fixed it. With 196 re-visits outstanding, the board would have filled
--    with permanently-unfixable rows, which is how a monitor stops being read.
--
--    The successor report is the documentation of record, and it IS audited in
--    full. So the skip is now "superseded" — sent back out, whether or not the
--    answer has arrived yet. duplicate_report already understood this
--    (revisit_done_pm_id is null on both sides); the rest now agree with it.
--
--    A superseded original does not vanish from the console: it is on the
--    re-shoot banner, on the billing-hold panel until the hold is released or
--    credited, and audit_done_hold_open in fn_integrity_check reds if the hold
--    is forgotten. Nothing loses its exit.
--
-- 2. NO-PLATE UNITS HAD NO WAY TO STOP RE-ASKING.
--    A technician ticking "no serial number — plate missing or unreadable" on
--    a unit already on Freshpet's list wrote that fact onto the REPORT and
--    nowhere else. assets.no_serial stayed false, so the box was not pre-ticked
--    next cycle, the portal still showed a serial for a unit that carries no
--    plate, and the informational finding re-raised on every future visit with
--    no way to answer it once and for all.
--
--    The check's own words are "needs reconciling against the asset list", so
--    the finding now stands only while the asset list has NOT recorded it. An
--    admin records it from the finding (one click, sets assets.no_serial), and
--    new no-plate discoveries at other units still raise normally. A discovery
--    that has not been recorded is counted by the new integrity check, so
--    "close it by ignoring it" is not one of the exits.

create or replace function public.fn_pm_nightly_audit(p_days integer default 45)
 returns table(audit_check text, open_count integer)
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare
  v_since date := (current_date - p_days);
begin
  create temp table _f (pm_id bigint, check_name text, severity text, detail text) on commit drop;

  with pm as (
    select c.*,
           -- Sent back out to be done again: either still owed, or already
           -- answered by a re-shoot. Either way this report is no longer the
           -- documentation of record and cannot be fixed in place.
           ((c.revisit_requested_at is not null and c.revisit_done_at is null)
             or c.revisit_done_pm_id is not null) as superseded,
           coalesce(array_length(c.photo_paths, 1), 0) as n_photos,
           exists (select 1 from unnest(c.photo_paths) p
                   where p ~ '_photo_[0-9]+_[a-z]+_[0-9]+\.jpg$') as kinds_tagged,
           array(select substring(p from '_photo_[0-9]+_([a-z]+)_[0-9]+\.jpg$')
                 from unnest(c.photo_paths) p) as kinds
    from public.completed_pms c
    where c.pm_date >= v_since
      and not c.prev_comp
      and coalesce(c.form_data->>'legacy','') <> 'true'
  )
  insert into _f
  select id, 'photos_none', 'red', 'No photographs on this report at all.'
  from pm where visit_type in ('pm','reshoot') and n_photos = 0 and not superseded
  union all
  select id, 'photos_missing', 'red',
         'Missing required photo: ' || array_to_string(missing, ', ') || '.'
  from (
    select id, array_remove(array[
      case when not ('unit' = any(kinds)) then 'full pic of unit' end,
      case when not ('plate' = any(kinds)) and not ('interior' = any(kinds)) then 'serial plate' end,
      case when not ('bottom' = any(kinds)) then 'bottom of unit' end
    ], null) as missing
    from pm where visit_type in ('pm','reshoot') and n_photos > 0 and kinds_tagged and not superseded
  ) q where cardinality(missing) > 0
  union all
  select p.id, 'photo_reused', 'red',
         'A photograph on this report also appears on report(s) ' || array_to_string(d.others, ', ') || '.'
  from pm p
  join lateral (
    select array_agg(distinct o.id order by o.id) as others
    from unnest(p.photo_hashes) h
    join public.completed_pms o on o.id <> p.id and h = any(o.photo_hashes)
    where h is not null
  ) d on d.others is not null
  where not p.superseded
  union all
  -- Billing, not documentation: stays visible on a stop awaiting re-shoot.
  select p.id, 'duplicate_report', 'amber',
         'Another report exists for this serial within 10 days (report ' || o.id || ').'
  from pm p
  join public.completed_pms o
    on o.serial = p.serial and o.id <> p.id and not o.prev_comp
   and abs(o.pm_date - p.pm_date) <= 10
  where p.visit_type = 'pm' and o.visit_type = 'pm'
    and p.revisit_of is null and o.revisit_of is null
    and p.revisit_done_pm_id is null and o.revisit_done_pm_id is null
  union all
  select id, 'default_readings', 'amber',
         'Readings are the old pre-filled defaults exactly (SP1 41F, 120V, 38F) — confirm they were measured.'
  from pm
  where visit_type in ('pm','reshoot') and not superseded
    and form_data->>'sp1' = '41°F' and form_data->>'voltage' = '120' and form_data->>'intTemp' = '38°F'
  union all
  select id, 'signature_missing', 'red',
         'No store signature and no "no contact available" on the report.'
  from pm
  where visit_type in ('pm','reshoot') and not superseded
    and coalesce((form_data->>'noContact')::boolean, false) = false
    and nullif(trim(coalesce(form_data->>'storeContact','')), '') is null
  union all
  select id, 'exception_thin', 'amber',
         'Exception report with ' ||
         case when nullif(trim(coalesce(form_data->>'comments','')),'') is null and n_photos = 0
                then 'no note and no photograph'
              when nullif(trim(coalesce(form_data->>'comments','')),'') is null then 'no note'
              else 'no photograph' end || '.'
  from pm
  where visit_type = 'exception' and not superseded
    and (nullif(trim(coalesce(form_data->>'comments','')),'') is null or n_photos = 0)
  union all
  select pm.id, 'no_serial_plate', 'info',
         'Serial plate missing or unreadable — needs reconciling against the asset list.'
  from pm
  where pm.no_serial_plate and not pm.superseded
    and not exists (select 1 from public.assets a
                     where a.id = pm.asset_id and a.no_serial);

  insert into public.pm_audit_findings (pm_id, check_name, severity, detail)
  select f.pm_id, f.check_name, min(f.severity),
         string_agg(distinct f.detail, ' ' order by f.detail)
  from _f f group by f.pm_id, f.check_name
  on conflict (pm_id, check_name) do update
    set last_seen = now(), severity = excluded.severity, detail = excluded.detail,
        resolved_at = null;

  update public.pm_audit_findings f
     set resolved_at = now()
   where f.resolved_at is null
     and not exists (select 1 from _f x where x.pm_id = f.pm_id and x.check_name = f.check_name)
     and exists (select 1 from public.completed_pms c where c.id = f.pm_id and c.pm_date >= v_since);

  return query
    select f.check_name, count(*)::int
    from public.pm_audit_findings f
    where f.resolved_at is null and f.dismissed_at is null
    group by f.check_name order by 2 desc;
end;
$function$;

create or replace function public.fn_integrity_check()
 returns table(severity text, check_name text, n integer, detail text)
 language sql
 stable security definer
 set search_path to 'public'
as $function$
  with c as (
    select 'red'::text as severity, 'hold_without_audit' as check_name,
      (select count(*) from completed_pms where billing_hold_at is not null
         and billing_hold_outcome is null and revisit_requested_at is null)::int as n,
      'Money held on a report with no re-visit ordered — cancelling a re-visit used to leave this, and the hold had no way to close.' as detail
    union all select 'red', 'photos_stranded',
      (select count(*) from completed_pms
        where form_data ? 'revisit_cleared_photos'
          and coalesce(array_length(photo_paths,1),0) = 0
          and revisit_requested_at is null and revisit_done_at is null)::int,
      'Photographs disconnected for a re-visit that was then cancelled — the report shows nothing and nobody is going back.'
    union all select 'red', 'replacement_never_closed',
      (select count(*) from completed_pms r join completed_pms o on o.id = r.revisit_of
        where r.visit_type in ('reshoot','exception') and o.revisit_done_at is null)::int,
      'A re-shoot was filed but the original still reads as owed — fn_close_revisit did not run or failed.'
    union all select 'red', 'dangling_revisit_pointer',
      (select count(*) from completed_pms p where p.revisit_done_pm_id is not null
         and not exists (select 1 from completed_pms x where x.id = p.revisit_done_pm_id))::int,
      'A report points at a replacement that no longer exists.'
    union all select 'red', 'dangling_revisit_of',
      (select count(*) from completed_pms p where p.revisit_of is not null
         and not exists (select 1 from completed_pms x where x.id = p.revisit_of))::int,
      'A re-shoot points at an original that no longer exists.'
    union all select 'red', 'asset_hidden_from_both_sides',
      (select count(*) from assets where source='field' and not active and reported=false)::int,
      'A field-found unit that is inactive AND unreported: the console only loads active assets and the portal hides inactive ones, so it exists and neither side can see it.'
    union all select 'red', 'candidate_nobody_is_visiting',
      (select count(*) from v_candidate_coverage
        where status='open' and not revisit_scheduled and not on_someones_route)::int,
      'A suspected extra cooler at a store that is on NOBODY''S route and has no re-visit — the technician will never be prompted, so this one waits for the next PM cycle or a trip somebody schedules.'
    union all select 'amber', 'audit_done_hold_open',
      (select count(*) from completed_pms where billing_hold_at is not null
         and billing_hold_outcome is null and revisit_done_at is not null)::int,
      'Re-documented, but the hold is still open — release it or credit it.'
    union all select 'amber', 'no_plate_not_on_asset_list',
      (select count(distinct p.asset_id) from completed_pms p
        where p.no_serial_plate and p.asset_id is not null
          and p.revisit_done_pm_id is null
          and not (p.revisit_requested_at is not null and p.revisit_done_at is null)
          and exists (select 1 from assets a where a.id = p.asset_id and not a.no_serial))::int,
      'A technician found no serial plate on a unit the asset list says has a serial — record it on the asset, or the question is asked again every cycle.'
    union all select 'amber', 'candidate_waits_for_next_cycle',
      (select count(*) from v_candidate_coverage
        where status='open' and not revisit_scheduled and on_someones_route)::int,
      'A suspected extra cooler at a store on a route but with no re-visit ordered — the technician is prompted next time he is there, which may be the next PM cycle.'
    union all select 'amber', 'candidates_open',
      (select count(*) from asset_list_candidates where status='open')::int,
      'Plate reads not on the asset list, awaiting a serial confirmed on site. Confirm or dismiss each one.'
    union all select 'amber', 'incident_closed_with_open_holds',
      (select case when exists (select 1 from incidents where status='closed')
                    and exists (select 1 from completed_pms where billing_hold_at is not null and billing_hold_outcome is null)
              then 1 else 0 end)::int,
      'An incident is closed while money is still on hold — one of the two is wrong.'
    union all select 'amber', 'review_flag_on_resolved',
      (select count(*) from completed_pms where needs_review and audit_flag='resolved')::int,
      'Marked resolved but still flagged for review.'
    union all select 'amber', 'orphan_audit_finding',
      (select count(*) from pm_audit_findings f
        where not exists (select 1 from completed_pms x where x.id = f.pm_id))::int,
      'An audit finding about a report that no longer exists.'
    union all select 'amber', 'orphan_found_on_pm',
      (select count(*) from assets a where a.found_on_pm_id is not null
         and not exists (select 1 from completed_pms x where x.id = a.found_on_pm_id))::int,
      'An asset cites the report that found it, and that report is gone.'
    union all select 'amber', 'customer_incident_no_report',
      (select count(*) from incidents where customer_facing and coalesce(summary,'') = '')::int,
      'A customer can open this incident and there is nothing written in it.'
  )
  select severity, check_name, n, detail from c where n > 0
  order by case severity when 'red' then 0 else 1 end, n desc;
$function$;
