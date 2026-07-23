-- Field-added ("found in the field") assets + PM modification tracking.
--
-- Field techs can now open a CLOSED route stop and either re-open & modify a
-- submitted PM, or register a NEW asset they found at that store and run the
-- full PM on it. Those assets are tagged source='field' and start
-- reported=false — they surface in the admin console's "Added Assets" tab as
-- new UN-REPORTED assets until an admin confirms Freshpet has been told about
-- the unit. The PM done on a freshly added asset is flagged added_asset=true
-- (surfaces under Needs Review with an "Added asset" subheading) and can be
-- billed to Freshpet / paid to the vendor from that same tab.
--
-- Applied to Supabase project mmkncrsaijexezmhfmiw on 2026-07-23.

alter table public.assets
  add column if not exists source text not null default 'import',
  add column if not exists added_by text,
  add column if not exists added_at timestamptz,
  add column if not exists reported boolean not null default true,
  add column if not exists reported_at timestamptz,
  add column if not exists reported_by text;

comment on column public.assets.source is '''import'' = Freshpet spreadsheet; ''field'' = added by a tech in the field';
comment on column public.assets.reported is 'false = Freshpet has not yet been told this unit exists (un-reported field find)';

alter table public.completed_pms
  add column if not exists added_asset boolean not null default false,
  add column if not exists modified_at timestamptz,
  add column if not exists modified_by text;

comment on column public.completed_pms.added_asset is 'PM performed on an asset the tech added in the field (Needs Review · Added asset)';
comment on column public.completed_pms.modified_at is 'last time this PM was re-opened and updated after the original submit';

-- Any signed-in field user may register a FIELD-FOUND asset. Spreadsheet
-- imports/updates stay admin-only: the insert must carry source='field' (and
-- arrive un-reported), so this policy cannot be used to bulk-load accounts.
drop policy if exists "Techs can add field-found assets" on public.assets;
create policy "Techs can add field-found assets"
on public.assets for insert to authenticated
with check (
  source = 'field'
  and reported = false
  and exists (select 1 from tech_profiles tp where tp.email = (auth.jwt() ->> 'email'))
);

-- A tech may attach a stop to their OWN route (used to pin a field-added asset
-- onto the stop where it was found). The one-active-tech-per-asset unique
-- index still prevents claiming an asset that's on another tech's route.
drop policy if exists "Techs can self-assign route stops" on public.route_assignments;
create policy "Techs can self-assign route stops"
on public.route_assignments for insert to authenticated
with check (tech_email = (auth.jwt() ->> 'email'));
