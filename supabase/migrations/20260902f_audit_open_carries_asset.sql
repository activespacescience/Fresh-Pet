-- Applied live 2026-09-02.
--
-- The audit board could show a no-plate finding but not answer it: the view
-- carried the report and not the UNIT, so "reconcile against the asset list"
-- had nowhere to happen. It now carries asset_id and whether the asset list
-- already records the missing plate, so the console offers "Record: no plate"
-- exactly once per unit and hides it the moment the fact is on file.
--
-- New columns are APPENDED. CREATE OR REPLACE cannot reorder or rename a view's
-- columns — inserting asset_id in the middle fails with "cannot change name of
-- view column".
create or replace view public.v_pm_audit_open as
 select f.id, f.pm_id, f.check_name, f.severity, f.detail, f.first_seen,
        f.last_seen, f.resolved_at, f.notified_at, f.dismissed_at, f.dismissed_by,
        c.store, c.serial, c.pm_date, c.tech_name, c.pdf_path,
        c.revisit_requested_at is not null and c.revisit_done_at is null as awaiting_reshoot,
        c.revisit_done_at is not null as reshoot_done,
        c.asset_id,
        coalesce(a.no_serial, false) as asset_no_serial
   from pm_audit_findings f
   join completed_pms c on c.id = f.pm_id
   left join assets a on a.id = c.asset_id
  where f.resolved_at is null and f.dismissed_at is null
    and not (fn_audit_check_is_documentation(f.check_name) and c.revisit_requested_at is not null);
