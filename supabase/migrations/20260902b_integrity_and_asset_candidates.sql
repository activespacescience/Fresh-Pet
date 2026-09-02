-- ONE SOURCE FOR THE ASSET-LIST NUMBERS, AND A CHECK THAT FINDS LOOSE ENDS.
--
-- Two things went wrong and both are the same shape: a number computed in more
-- than one place drifts, and a state that can be entered but not exited strands
-- work where nobody looks.
--
--  * The incident said "12 coolers photographed whose serials match nothing on
--    the list"; the portal showed 8; the underlying analysis listed 29. Three
--    numbers for one fact, none of them reading the same source.
--  * That 29-serial analysis produced a list and NOTHING consumed it. 25 of
--    those serials are still not on the asset list and never became a record.
--    An artifact in a folder is not a system.

-- ── 1. Candidates: a plate we photographed whose serial is not on the list ───
-- These are NOT assets. A plate read is evidence a unit exists, not proof of
-- which unit -- the read can be a misread, or the photo can belong to the store
-- next door. So they get their own table with a close-out path, and NOTHING
-- here reaches Freshpet until a human confirms it on site and it becomes a real
-- asset row. Without this they have nowhere to live except a CSV.
create table if not exists public.asset_list_candidates (
  id            bigserial primary key,
  store         text not null,
  address       text,
  serial_read   text,
  tier          text not null,
  evidence      text,
  signature     text,
  source_pm_id  bigint references public.completed_pms(id) on delete set null,
  units_listed  int,
  status        text not null default 'open',
  resolution    text,
  asset_id      bigint references public.assets(id) on delete set null,
  resolved_at   timestamptz,
  resolved_by   text,
  created_at    timestamptz not null default now(),
  constraint asset_list_candidates_status_check
    check (status in ('open','confirmed','dismissed','already_listed')),
  -- A closed candidate must say how it closed. This is the whole point: the
  -- previous version of this list closed by being forgotten.
  constraint asset_list_candidates_closed_shape
    check (status = 'open' or (resolution is not null and resolved_at is not null))
);
create index if not exists asset_list_candidates_open_idx
  on public.asset_list_candidates (status) where status = 'open';

alter table public.asset_list_candidates enable row level security;
drop policy if exists asset_list_candidates_staff on public.asset_list_candidates;
create policy asset_list_candidates_staff on public.asset_list_candidates
  for all to authenticated using (public.fp_is_field_user()) with check (public.fp_is_field_user());

comment on table public.asset_list_candidates is
  'Plate reads not on Freshpet''s asset list. Staff-only, never shown to the customer until confirmed on site. See 20260902b.';

-- ── 2. The asset-list numbers, computed once ────────────────────────────────
-- Every surface that states one of these reads THIS. A second implementation is
-- how the incident and the portal came to disagree.
create or replace function public.fn_asset_list_status()
returns table (
  found_open        int,
  found_no_plate    int,
  found_reconciled  int,
  missing_open      int,
  missing_reconciled int,
  candidates_open   int,
  hidden            int
)
language sql stable security definer set search_path to 'public' as $$
  select
    (select count(*) from assets where source='field' and active and reported=false)::int,
    (select count(*) from assets where source='field' and active and reported=false and no_serial)::int,
    (select count(*) from assets where source='field' and active and reported=true)::int,
    (select count(*) from completed_pms p where p.visit_type='exception'
       and not exists (select 1 from assets a where a.id=p.asset_id and a.active=false))::int,
    (select count(*) from completed_pms p where p.visit_type='exception'
       and exists (select 1 from assets a where a.id=p.asset_id and a.active=false))::int,
    (select count(*) from asset_list_candidates where status='open')::int,
    (select count(*) from assets where source='field' and not active and reported=false)::int;
$$;
grant execute on function public.fn_asset_list_status() to authenticated;

-- ── 3. Every way a thing can be left half-closed ────────────────────────────
create or replace function public.fn_integrity_check()
returns table (severity text, check_name text, n int, detail text)
language sql stable security definer set search_path to 'public' as $$
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
    union all select 'amber', 'audit_done_hold_open',
      (select count(*) from completed_pms where billing_hold_at is not null
         and billing_hold_outcome is null and revisit_done_at is not null)::int,
      'Re-documented, but the hold is still open — release it or credit it.'
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
$$;
grant execute on function public.fn_integrity_check() to authenticated;
