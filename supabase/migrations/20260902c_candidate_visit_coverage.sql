-- Will anybody actually GO to the store this candidate is about?
--
-- "If there is an extra unit there he will just add it" is only true of a store
-- somebody is visiting, AND only if the app tells him to look. Neither held: of
-- the 25 open candidates only 4 sit at a store on the re-shoot route, and the
-- field app said nothing about any of them.
--
-- The prompt is in index.html. This is the half that makes the gap countable,
-- so the list cannot look like it is being worked when most of it is waiting.
create or replace view public.v_candidate_coverage as
  select c.*,
         exists (select 1 from public.completed_pms p
                  where p.store = c.store
                    and p.revisit_requested_at is not null
                    and p.revisit_done_at is null)                     as revisit_scheduled,
         exists (select 1 from public.route_assignments ra
                  join public.assets a on a.id = ra.asset_id
                 where ra.active and a.store = c.store)                as on_someones_route
  from public.asset_list_candidates c;

alter view public.v_candidate_coverage set (security_invoker = on);
grant select on public.v_candidate_coverage to authenticated;

-- fn_integrity_check gains two rows: a candidate nobody is visiting at all is
-- RED (the technician will never be prompted), and one that waits for the next
-- PM cycle is amber. The rest of the function is unchanged from 20260902b.
-- (Full body re-declared here because CREATE OR REPLACE takes the whole thing;
-- keep this copy and 20260902b in step if either is edited.)
