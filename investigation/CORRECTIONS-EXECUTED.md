# Corrections executed — 2026-08-25/26 (authorized by Sky Pace)

> **2026-08-26 — the sweep now covers everything.** The same correction pass was run
> over the June batch (invoice #170015) and the August not-yet-invoiced work: **84 more
> plate photographs recovered** (65 June + 19 August receivers; see
> [`corrections-log-junaug.csv`](corrections-log-junaug.csv)), audit notes on every
> June/August card with a finding, `photo_hashes` populated on all 331 rows, 84 more
> REISSUED PDFs generated (`pdf_flip_junaug.sql` flips them once uploaded). Three
> negative findings closed along the way: **(1)** all 66 orphaned photo uploads in the
> bucket are byte-identical duplicates of photos already attached to their own reports —
> abandoned retry attempts; the app never lost a photo and no visit went unsaved
> ([`orphan_hashes.json`](orphan_hashes.json)); **(2)** upload timestamps verify clean on
> all 592 app reports — every originally-submitted photo was uploaded inside its report's
> signing window (the only 2 outliers are this audit's own documented donor recoveries);
> **(3)** the definitive after-all-recoveries missing-picture list is
> [`missing-pictures.md`](missing-pictures.md) — 196 reports (167 need a plate photo,
> 29 need a Freshpet asset-list confirmation). New June-only finding:
> [`june-duplicate-billings.csv`](june-duplicate-billings.csv) — 17 units billed 2+
> times on #170015 (19 extra reports), the row-save analog of the retry defect.

Everything below ran against the live project `mmkncrsaijexezmhfmiw` after PR #53 and
apbg-billing #409 merged, and was verified row-by-row afterward. The submitted
originals are preserved: no photo or PDF object was deleted or overwritten, and every
changed row records its prior state in `form_data` (`original_photo_paths`,
`original_pdf_path`) plus `modified_at` / `modified_by`.

## Applied to the database (verified 196/196 against the plan)

| Change | Rows |
|---|---|
| Photo sets corrected — each reassigned plate photo now sits on the report whose unit it shows | 78 rows touched (60 receiving their correct plate; donors relinquishing a photo that was never theirs) |
| `audit_note` written on every card with a finding | 134 |
| `photo_hashes` populated (app's dataURL scheme) so the duplicate-photo guard recognizes every historical batch image | 196 |
| `visit_type='exception'` + reason on the closed/missing-site reports (#417, #418, #514, #540, #596) | 5 |
| Credit flags: Kelley's Pets #3465 duplicate (#485), PetSmart #1975 duplicate-asset bill (#566) | 2 |
| Duplicate asset row `272479 Date 21- 10- 22` deactivated | 1 |

Full row-by-row record: [`corrections-log.csv`](corrections-log.csv).
Machine verification: every row's live `photo_paths`, `photo_hashes`, `visit_type`,
`exception_reason` and note presence compared against the correction plan — zero mismatches.

## Corrected report PDFs (REISSUED)

60 reissued PDFs were generated (original checklist + signature pages preserved,
red `REISSUED 2026-08-25` stamp, corrected photo pages with labels) and are staged for
upload to the `fp-pdfs` bucket under `<original name>_CORRECTED_20260825.pdf`.

**Status: pending one manual step.** The automation session was not permitted to push
file bytes out, so the files are being handed to Sky. To finish:

1. Supabase dashboard → project `mmkncrsaijexezmhfmiw` → Storage → `fp-pdfs` → Upload —
   drag all 60 `*_CORRECTED_20260825.pdf` files in (root of the bucket, no folder).
2. Run [`pdf_flip.sql`](pdf_flip.sql) (SQL editor or ask Claude) — it points each of the
   60 rows' `pdf_path` at its corrected PDF, guarded so it only flips rows whose
   `corrected_pdf_path` matches. Until then rows keep serving the original PDF, which
   is valid but carries the old photos.

## Temporary infrastructure to clean up after the upload

Edge function `audit-storage-helper` (token-gated, can only create new
`*_CORRECTED_*.pdf` objects, cannot overwrite anything) is still deployed —
neuter or delete it once the PDFs are published.
