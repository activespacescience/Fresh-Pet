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

Full row-by-row record: [`corrections-log.csv`](corrections-log.csv). The same facts are
queryable live — every changed row carries `modified_by = 'audit correction 2026-08-25
(approved by skypace@brixbev.com)'` and its `form_data.audit_note`.
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

## Paper field forms recovered (2026-08-26)

Five paper *Preventative Maintenance Service Checklist* sheets were supplied by the owner
and filed. Scans are in [`field-forms/`](field-forms/) and each one is referenced from its
report card (`form_data.field_form_scan`) with a note. **They must also be uploaded to the
`fp-photos` bucket** under the same filenames for the app to display them — an automated
session cannot write to that bucket (uploads require an authenticated session).

They are evidence in the opposite direction from the invoice review: at three of the five
stores the technician recorded **more units on site than the Freshpet asset list carries**,
two of them attested by a store employee's signature. Notably this explains report #494
(Walmart #5632), previously flagged only as "plate reads a serial not on the asset list".

Full cross-batch analysis: [`asset-list-undercount.md`](asset-list-undercount.md) /
[`.csv`](asset-list-undercount.csv) — 34 locations in three evidence tiers (5 paper forms,
20 plate mismatches at single-unit stores, 9 at multi-unit stores).

⚠ Two cautions carried into the report and onto the cards: the Walmart #2001 sheet is a
**field note, not a service record** (no date, no checklist marks, no signatures — no PM is
billed from it), and the second serial on the Walmart #1972 form (read as **10213740**,
absent from the system entirely) is a handwriting reading that needs confirming against the
physical plate.


## Round 2 — foreign plate photos removed, exception and new-asset reports restamped (2026-08-28)

The first correction pass attached each unit's correct plate photograph but did not
**detach** the foreign one, so a report could still display another store's equipment.
That is closed:

| Change | Count |
|---|---|
| Reports from which a photograph of another unit was removed | 73 (32 June, 27 July, 14 August) |
| Photographs detached (kept on file, nothing deleted from storage) | 76 |
| Reports left with no photograph, which now say so explicitly | 6 |
| Closed-store / unit-not-found reports rebuilt as a single stamped page | 5 |
| Field-added asset reissued with a green NEW ASSET cover | 1 |
| Corrected PDFs published and `pdf_path` flipped | 79 |

Verified after the flip: `unflipped = 0`, `dangling = 0` — every row carrying a
`corrected_pdf_path` points at it, and every path resolves to a real object.

**Note on the corrected-PDF count.** The bucket now holds three generations
(53 × `_20260825`, 72 × `_20260826`, 79 × `_20260828`) totalling **204** current corrected
reports, not 223. Nineteen reports were corrected twice — once for the plate reassignment
and again for the foreign-photo removal — and correctly hold only their latest PDF.

**Result on the customer's central complaint:** eight of the nine serials Freshpet listed
now appear on exactly one report. The ninth (10961123) is their own Kelley's Pets duplicate
submission — the same unit with two reports, so the plate photograph is correct on both.
Corpus-wide only three serials appear on more than one report and every one is the same
physical unit with duplicate reports, not a misfiled photograph.

## Temporary infrastructure — BOTH RETIRED

`audit-storage-helper` (retired 2026-08-26) and `audit-pdf-publish` (retired 2026-08-28)
are both redeployed as stubs returning HTTP 410. Verified by calling each with its own
valid token, including a write attempt — both refused. Both tokens are inert.

`audit-pdf-publish` assembled PDFs inside the project from objects already in the buckets,
so no document bytes were transferred from the audit session. It could only create names
matching `*_CORRECTED_<yyyymmdd>.pdf` with `upsert:false`, so it could never overwrite an
original report.
