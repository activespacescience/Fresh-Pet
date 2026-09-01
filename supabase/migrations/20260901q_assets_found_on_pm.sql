-- Which visit found a field-added asset.
--
-- A field-found unit is evidence of a gap in Freshpet's asset list, and the
-- report that noted it is the evidence. Without this the portal can show the
-- row but not what it is based on -- and a claim on a customer's asset list
-- with nothing behind it is exactly what this whole exercise was about.
--
-- Nullable: assets predating the field-add flow have no such visit, and a unit
-- noted in a comment on ANOTHER unit's report is still linked here even though
-- it has no PM of its own yet.
alter table public.assets
  add column if not exists found_on_pm_id bigint references public.completed_pms(id) on delete set null;

create index if not exists assets_found_on_pm_idx on public.assets (found_on_pm_id)
  where found_on_pm_id is not null;

comment on column public.assets.found_on_pm_id is
  'The completed_pms report on which this unit was first noted. See 20260901q.';

-- Backfill for the assets the field app already added: the earliest PM filed
-- against the asset is the visit it was added on.
update public.assets a
   set found_on_pm_id = p.id
  from public.completed_pms p
 where a.source = 'field' and a.found_on_pm_id is null
   and p.asset_id = a.id
   and p.id = (select min(x.id) from public.completed_pms x where x.asset_id = a.id);
