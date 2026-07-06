-- A stop (asset) may belong to at most ONE tech's active route.
-- Previously enforced only in the admin/field client JS; this makes the
-- database the source of truth so concurrent admins or the field app cannot
-- double-assign a store. Partial index (WHERE active) so historical
-- deactivated rows never block a re-assignment.
--
-- Applied to Supabase project mmkncrsaijexezmhfmiw on 2026-07-06.
CREATE UNIQUE INDEX IF NOT EXISTS route_assignments_one_active_tech_per_asset
ON public.route_assignments (asset_id)
WHERE active;
