-- Applied live 2026-09-02.
--
-- PETCO #372 — the two reports filed on 2026-09-02 documented the wrong coolers,
-- and the record said the opposite. Realigned.
--
-- Three near-identical Minus Forty UDGR43 units stand in a row there: 240761,
-- 240766, 307516. Read off the plate photographs:
--   report 686, filed as 240766 -> its plate reads 307516
--   report 687, filed as 240761 -> its plate reads 240766
--   240761 -> never photographed at all
-- Everything shifted one place down the row. Every existing control passed: the
-- photographs are unique (no reuse), all three required kinds are present, PDF
-- and signature on file. Only reading the plate catches it, which is why
-- plate-read now runs on the phone.
--
-- WHAT WAS FALSE AND IS NOW TRUE. Originals 11 (240766) and 6 (240761) read as
-- RE-DOCUMENTED, closed by 686/687. Neither had been. Both are re-opened, so
-- all four units at that store now read as owed and one trip settles it:
--   6  240761  owed - never photographed
--   11 240766  owed - its photographs are sitting on report 687
--   12 307516  owed - its photographs are sitting on report 686
--   9  4770049 owed - never visited (the True unit)
--
-- WHY THE PHOTOGRAPHS WERE NOT SIMPLY RE-FILED ONTO THE RIGHT UNITS. Tempting,
-- and probably what happened physically — each report holds a coherent set of
-- pictures of ONE cabinet. But the only thing PROVEN is what each plate says.
-- Which cabinet the unit and bottom shots belong to is an inference, and the
-- filenames and the rendered PDF both carry the wrong serial, so a re-file that
-- changed one row would leave a document contradicting itself. Guessing at
-- identity to make a record look tidy is the defect this remediation is about.
-- The stops go back out; the photographs stay on file as a record of the visit.
--
-- 686/687 are DETACHED (revisit_of cleared) rather than deleted: they are real
-- pictures of real machines taken that day, they are flagged needs_review, and a
-- re-shoot row is never billable. Detaching them created a shape that did not
-- exist before — a re-shoot pointing at no original — so fn_integrity_check
-- gains `reshoot_documents_nothing` to watch it. Nothing enters a state here
-- without something able to see it.

update public.completed_pms
   set revisit_done_at = null, revisit_done_pm_id = null,
       needs_review = true, audit_flag = 'needs_plate_photo',
       modified_at = now(),
       modified_by = 'audit — re-shoot documented the wrong unit, closure reversed'
 where id in (6, 11);

update public.completed_pms
   set revisit_of = null,
       modified_at = now(),
       modified_by = 'audit — detached: plate does not match the unit on the report'
 where id in (686, 687);

-- fn_integrity_check gains, before the audit_done_hold_open branch:
--
--   union all select 'amber', 'reshoot_documents_nothing',
--     (select count(*) from completed_pms
--       where visit_type = 'reshoot' and revisit_of is null)::int,
--     'A re-shoot report attached to no original — it was filed against the
--      wrong unit and detached. The stop it was meant to document is owed
--      again; decide whether to re-file these photographs or leave them as a
--      record of the visit.'
--
-- Applied by reading pg_get_functiondef and inserting at that anchor, raising
-- if the anchor had moved — never by rebuilding the function from a copy.
