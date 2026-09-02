-- Applied live 2026-09-02.
--
-- A RE-SHOOT IS NEVER BILLED. Not the re-shoot report, and not the original it
-- replaces — the STOP is not charged to Freshpet.
--
-- Only half of that was true. freshpet-invoice excluded visit_type 'reshoot'
-- (the new report), but the ORIGINAL is an ordinary 'pm' row: closing its
-- billing hold as 'released' dropped it straight back into the billable pool,
-- and the confirm text said "the charge stands and Freshpet should pay it".
-- 19 of the 197 open holds sit on lines that were never invoiced, so there
-- 'released' would not have reinstated a charge — it would have CREATED one,
-- for the very stop whose documentation we told the customer we could not stand
-- behind.
--
-- The rule now lives in the database, because a rule that lives in a function is
-- a rule until somebody writes another function. Three layers, this being the
-- one that cannot be talked round:
--   1. tg_reshot_never_billed  — billed can never be set on a re-shot stop
--   2. freshpet-invoice        — such rows are never proposed, with a stated reason
--   3. the admin hold panel    — "release to invoice" is not offered on one
-- and fn_integrity_check reds if the forbidden state ever exists anyway.
--
-- The TECHNICIAN is unaffected and deliberately so: payouts run off paid_out and
-- never look at visit_type or at this. He did the work twice and is paid twice.
--
-- The trigger fires on INSERT as well as UPDATE. Nothing inserts a billed row
-- today, which is exactly the sort of thing that stays true until somebody
-- writes an importer.

create or replace function public.fn_guard_reshot_never_billed()
returns trigger
language plpgsql
as $function$
begin
  if new.billed and not coalesce(old.billed, false) then
    if new.revisit_done_pm_id is not null then
      raise exception
        'Report % was re-shot (replaced by report %). A re-shot stop is never billed to Freshpet.',
        new.id, new.revisit_done_pm_id
        using errcode = 'check_violation';
    end if;
    if new.visit_type in ('reshoot','exception') then
      raise exception
        'Report % is a %. That visit type is never billed to Freshpet.',
        new.id, new.visit_type
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end;
$function$;

drop trigger if exists tg_reshot_never_billed on public.completed_pms;
create trigger tg_reshot_never_billed
  before insert or update on public.completed_pms
  for each row execute function public.fn_guard_reshot_never_billed();

-- A third exit for a hold. 'released' means the charge stands and Freshpet pays
-- it; 'credited' means money goes back. Neither describes an UNBILLED line on a
-- stop we re-shot: there is no charge to stand behind and nothing to credit. It
-- is simply never billed, and the record should say so rather than borrow a word
-- that means something else.
alter table public.completed_pms
  drop constraint if exists completed_pms_billing_hold_outcome_check;
alter table public.completed_pms
  add constraint completed_pms_billing_hold_outcome_check
  check (billing_hold_outcome is null
         or billing_hold_outcome = any (array['released','credited','not_billed']));

-- Two new reds. The first is not hypothetical: it fires today on 8 rows — the
-- 5 closed-store / unit-missing exceptions that shipped on invoice #172825
-- before the exception gate existed, and 3 June PMs on invoice #170015 that
-- have since been re-shot. Both need crediting; the check keeps saying so until
-- they are.
create or replace function public.fn_integrity_check()
 returns table(severity text, check_name text, n integer, detail text)
 language sql stable security definer set search_path to 'public'
as $function$
  with c as (
    select 'red'::text as severity, 'reshot_stop_billed' as check_name,
      (select count(*) from completed_pms
        where billed and (revisit_done_pm_id is not null or visit_type in ('reshoot','exception')))::int as n,
      'A stop we re-shot has been charged to Freshpet. A re-shoot is never billed — neither the re-shoot nor the visit it replaces.' as detail
    union all select 'red', 'reshot_hold_released',
      (select count(*) from completed_pms
        where revisit_done_pm_id is not null and billing_hold_outcome = 'released')::int,
      'A re-shot stop had its hold closed as "released", which means the charge stands. It cannot: close it as not billed, or credit it if it was already invoiced.'
    union all select 'red', 'hold_without_audit',
      (select count(*) from completed_pms where billing_hold_at is not null
         and billing_hold_outcome is null and revisit_requested_at is null)::int,
      'Money held on a report with no re-visit ordered — cancelling a re-visit used to leave this, and the hold had no way to close.'
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
      'Re-documented, but the hold is still open — close it as not billed if it never went out, or credit it if it is on an invoice.'
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

-- Oceana Market #604221 (report 662) was re-shot and was never invoiced, so
-- under the rule there is no decision left to make. Recorded as not billed.
update public.completed_pms
   set billing_hold_outcome = 'not_billed',
       billing_hold_closed_at = now(),
       billing_hold_closed_by = 'skypace@brixbev.com — re-shot stop, never billed to Freshpet'
 where id = 662 and billing_hold_outcome is null;
