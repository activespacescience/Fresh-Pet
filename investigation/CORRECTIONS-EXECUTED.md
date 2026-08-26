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

144 reissued PDFs were generated (60 July + 84 June/August; original checklist + signature pages preserved,
red `REISSUED` stamp, corrected photo pages with labels) and published to
the `fp-pdfs` bucket as `<original name>_CORRECTED_<YYYYMMDD>.pdf`.

**Status: COMPLETE (2026-08-26).** All 144 corrected PDFs (60 July + 84 June/August)
were uploaded to `fp-pdfs` by the owner and both flip scripts
([`pdf_flip.sql`](pdf_flip.sql), [`pdf_flip_junaug.sql`](pdf_flip_junaug.sql)) were
applied live. Verified afterward:

| Check | Result |
|---|---|
| Files present in `fp-pdfs` | 144 / 144 (60 × `_CORRECTED_20260825`, 84 × `_CORRECTED_20260826`) |
| Uploaded bytes match generated files | exact — per-file size + content hash, 47,088,229 bytes total |
| Rows whose `pdf_path` points at its intended corrected PDF | 144 / 144 |
| Flipped `pdf_path` values that resolve to a real object | 144 / 144 (0 dangling) |
| Original PDF path preserved in `form_data` | 144 / 144 |
| Original PDF objects still in storage | 144 / 144 (0 deleted or overwritten) |

Note on verification method: Supabase's storage eTag for these uploads is
`md5(md5_digest(content))` (single-part multipart form), **not** a plain content MD5 —
comparing against a plain MD5 produces a false mismatch.

## Temporary infrastructure — RETIRED

Edge function `audit-storage-helper` (token-gated, could only create new
`*_CORRECTED_*.pdf` objects, never overwrite) was **neutered on 2026-08-26**: it is
redeployed as a stub that returns HTTP 410 for every request and performs no action.
Verified by calling it with the original valid audit token, including a file-write
attempt — both refused with 410. The token is now inert; do not revive this function,
write a new purpose-scoped one if a future audit needs the capability.
