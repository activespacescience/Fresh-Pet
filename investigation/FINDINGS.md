# Freshpet PM Reporting Defects — Investigation Findings

**Invoice under review:** #172825 · **Batch:** 196 PM reports, service dates 2026-07-15 → 2026-07-31 · **Invoice total:** $5,880 (196 × $30)
**Investigated:** 2026-08-25, read-only, against the live Fresh-Pet Supabase project (`mmkncrsaijexezmhfmiw`), the stored report PDFs and photos (`fp-pdfs` / `fp-photos` buckets), and this repository's source.
**Evidence preserved:** nothing in the submitted batch was modified. All conclusions below are reproducible from the stored records.

---

## Executive summary

Freshpet's four defect categories reduce to **two root causes, both in our tooling and workflow — none in the field work itself**:

1. **Photo attachment was uncontrolled** (Categories 1, 3, 4). Photos were attached to reports from the tech's device gallery with nothing binding an image to the unit it claims to show, no duplicate detection, and no requirement that a serial-plate photo exist at all. **43 of 196 reports carry at least one image byte-identical (SHA-256) to an image on another report; 17 distinct images account for all of it** (one image appears on 13 different stores' reports). The "duplicate serial numbers" in Category 1 are the serials *legible in those reused plate photos* — the serial **fields** on the reports match the asset registry for each store and were never duplicated. Two of the nine alleged serials (M153303, M158123) do not exist anywhere in our records except inside reused photos.

2. **The app had no way to report a closed store or missing unit** (Category 2). The tech drove to all five flagged sites — the attached photos prove it (a boarded-up Walmart #1983; Foods Co #784 with CLOSED signs on the doors; the "Incredible Pets" address now an ACE Hardware; Comptons Market and Murphys Paw photographed on site). The only form the app would accept was a full PM checklist whose temperature and work fields were **pre-filled defaults** (38 °F / 41 °F — present on 184 of 196 reports batch-wide), and whose signature box the tech filled with a meaningless scribble to get past it. The "operational readings and manager signatures" on closed-store reports are template artifacts plus tech filler at a genuinely visited site — **not evidence of a visit that didn't happen, and not a forged signature of any real person** (the marks are unattributed strokes, distinct on every report; the tech's own signature is the app's auto-stamp).

**The field visits are real.** 149 of 196 reports carry photo sets that are unique in the entire batch (337 distinct images), daily submission sequences trace coherent geographic routes (Sacramento 7/15 → Bakersfield 7/20–21 → Fresno 7/22–23 → Modesto 7/24 & 7/29 → Tri-Valley 7/30–31), and 182 reports carry a named store contact. What failed was documentation discipline and the software that should have enforced it.

---

## The batch, precisely

| | |
|---|---|
| Reports on invoice #172825 | **196** (not ~200; each `completed_pms` row is stamped with the invoice number) |
| Reports with fully unique photos | **144** + 5 closed-store visits with unique site photos = **149** |
| Reports carrying ≥1 reused image | **43** (35 all-reused, 8 partially) |
| Reports with no photos at all | **4** |
| Closed-store / missing-unit reports | **5** |
| Technician | 1 (all 196) |
| Reports with GPS | **0** — location permission was never granted on the tech's device; the app silently recorded null |
| Reports with the prefilled default temps | **184** |
| Reports reopened/edited after submit | 10 (timestamped) |

Freshpet's arithmetic (95 validated + 67 unnoted = 162) leaves ~34 reports unaccounted for; we have asked for their full itemization (their Attachment 2 arrived 2026-08-25 and is being processed).

## Category 1 — "Duplicate serial numbers across locations"

**Confirmed as a photo defect, refuted as a data defect.** For every alleged serial we checked:

- The **report serial field** at each alleged store is that store's registry serial — all different, no duplication (`assets.serial` carries a unique constraint; the CSV import de-duplicates; the field-add flow rejects known serials).
- The alleged serial is the one **printed on the serial plate visible in a photo reused across those stores**. Example proven by direct image inspection: the image attached to Vons #1969's report is a True-cabinet plate clearly reading **11008872** — Food Maxx #453's unit — and that byte-identical file sits on reports at exactly the stores Freshpet lists under SN#11008872.
- Each alleged "duplicate serial group" maps onto a **route-day cluster** (stores serviced the same day or adjacent days), because the reuse happened during batched end-of-day report entry — two reports for different stores were signed as little as **28 seconds apart** on 7/20.
- The doubled reports Freshpet flagged are real and confirmed: **Kelley's Pets #3465** (two rows, same serial, 76 s apart — a double submission) and **Target #1417** (two sibling units whose reports share both photos, making them read as duplicates).

Full mapping: [`defect-table.md`](defect-table.md). Nearly every alleged (serial, store) pair lands on a report at that store carrying a byte-identical reused image; the few that don't were near-duplicate *separate shots* of the same wrong unit (caught by perceptual hashing, not byte comparison).

## Category 2 — Closed stores / missing units

All five reports are **documented real visits filed through the wrong form**, because no right form existed:

| Report | Store | What the attached photo shows | Signature box | Readings |
|---|---|---|---|---|
| #540, 7/23 | Walmart US #1983 | Boarded-up, closed building | unattributed scribble | app defaults |
| #514, 7/22 | Foods Co #784 | Storefront covered in CLOSED signs | unattributed scribble | app defaults |
| #418, 7/15 | Comptons Market #14696 | Storefront from the vehicle; no unit found | unattributed scribble | app defaults |
| #417, 7/15 | Incredible Pets #24012404 | Address is now an ACE Hardware | unattributed scribble | app defaults |
| #596, 7/30 | Murphys Paw #1910 | Open store, freezers inside; contact "Michelle" recorded | signed; flagged NEEDS REVIEW in-app | app defaults |

Determination: **(a) system-populated fields + (b) tech-entered filler at a site actually visited.** Not (c) — no report was filed for a site the tech did not attend; the photos, taken at the addresses, are the proof. The signature scribbles are a serious documentation-discipline failure (addressed below), but they are not signatures of any person, real or invented, and each is distinct — no signature asset was copied between reports.

## Categories 3 & 4 — Missing plates, reused equipment images, photos on wrong reports

Same root cause as Category 1. Specifics confirmed:

- **Target #1384 / Walmart #3139** ("10 % sales sticker"): byte-identical image on both reports, uploaded 7/21. The sticker anchors it to a third site; it can be identified from route records during re-verification.
- **Save Mart #92 / #54**: same pattern (per Freshpet; consistent with the hash clusters).
- The app **allowed zero photos** (4 reports shipped with none) and had **no concept of a serial-plate photo** — any image satisfied the eye.
- At multi-unit stores nothing tied a photo to a *specific* unit, so sibling-unit reports interleaved images (2 of 49 multi-unit stores in this batch share images between siblings; the within-store misfiling Freshpet reconciled by hand is this same gap).

## Hypotheses tested (from the handoff)

| # | Hypothesis | Verdict | Evidence |
|---|---|---|---|
| H1 | Sticky serial field state | **Ruled out** for serials — serials are registry-driven, never typed on a PM. A stale-index draft-resume hazard *did* exist and is fixed in this change, but no batch defect traces to it. |
| H2 | Photo→job binding by upload order | **Ruled out** — photos upload inside the submit call, named per-report; no cross-job binding step exists. |
| H3 | Offline sync collision | **Ruled out** — the app has no offline queue; submits are synchronous. |
| H4 | Report cloning | **Partially** — reports weren't cloned, but the prefilled form made every report *born identical* (readings/checkboxes), which is the same symptom reviewers keyed on. |
| H5 | Image-store deduplication | **Ruled out** — every upload stores a distinct object; identical *content* under different paths proves reuse at capture, not storage. |
| H6 | Multi-unit site logic | **Contributing** — units are distinct records, but nothing bound photos to a specific unit at multi-unit stops. |
| — | **Actual mechanism** | **Gallery attachment during batched paperwork.** Reports were completed in end-of-route sittings (cross-store submissions 28–177 s apart, 11 instances), photos picked from the camera roll, same images picked repeatedly across 8 days. |

Note on EXIF: the app canvas-re-encodes every photo at capture, deliberately stripping EXIF. The equivalent (stronger) diagnostic used here is cryptographic hashing of stored bytes: **one file, N references — a data/workflow defect, not N fabricated capture events.**

## The 95-report payment position

We do not accept it. The evidence for the work is independent of the defective attachments:

1. **149 reports carry photo evidence unique in the batch** — 337 distinct images of units, plates and sites, taken across coherent daily routes.
2. **182 reports carry a named store contact** who signed at an open store.
3. The 43 photo-defective reports and 4 no-photo reports describe **units that exist at those stores per Freshpet's own asset list**, serviced on route days the tech demonstrably worked in that city; we will **re-verify all 47 on site at no cost** rather than argue them (plan below).
4. The 5 closed-store reports document visits Freshpet's own asset list *required* us to route — the correct outcome is removing those sites from the list (and agreeing a trip-charge treatment), not deleting the visit.

## Corrective actions (shipped in this change)

| Gap that produced the defect | Control now in place |
|---|---|
| Any image accepted as "photos" | Photos are typed: **serial plate / unit / site**; the **plate photo is required** to submit a PM |
| Gallery attachment | Plate/unit/site photos come only from the **camera capture input**; gallery remains only for supplemental "other" images |
| Same image on many reports | **SHA-256 duplicate guard**: every photo is fingerprinted (`photo_hashes` column); an image whose hash already backs another report is refused at attach time, naming the report that owns it |
| Prefilled 38 °F/41 °F + pre-checked work items | Form starts **empty**; temperature, set point, and working-on-arrival are required entries |
| No closed-store outcome | New **Site Visit Exception** report: reason + mandatory storefront photo, no readings, no signatures, auto-flagged for review, **excluded from PM invoicing** in both the admin console and the server-side `freshpet-invoice` function |
| Scribbled store signatures | Explicit **“No store contact available to sign”** state that prints on the PDF; a store signature now requires the contact's name; the two can't coexist |
| Double submissions | One report per unit per day — a second submit is blocked and routed to the explicit edit path |
| Silent GPS nulls | GPS capture state (`captured`/`unavailable`) is stamped on every report; field devices must grant location before the next batch |
| Draft resume could land on the wrong unit | Drafts resume strictly by serial or not at all |

Database migration: [`supabase/migrations/20260825_pm_integrity_controls.sql`](../supabase/migrations/20260825_pm_integrity_controls.sql) — **apply before merging** (the app writes the new columns).

## Re-verification plan

[`reverification-units.csv`](reverification-units.csv) — **47 units** (43 reused-photo + 4 no-photo): Bakersfield 15, Modesto 13, Fresno 11, Sacramento 3, Tri-Valley 5. At the next route pass (≈4 route days, proposed within 2 weeks of Freshpet's agreement), the tech re-photographs each unit's serial plate and placement under the new controls — camera-only, hash-checked, plate-required — producing replacement evidence at no cost to Freshpet. The 5 closed/missing sites go back to Freshpet as asset-list corrections.

## Personnel determination

The batch is one technician's. The visits occurred; the documentation shortcuts (reused gallery photos at 43 stops over 8 days, scribbled store-signature boxes at closed stores) were a sustained practice, not a one-off slip, and warrant direct coaching plus written expectations — while noting the app invited every one of these shortcuts: it prefilled the "good" answers, accepted any or no photo, demanded a signature at a boarded-up store, and offered no honest way to say "this store is gone." The software now refuses the shortcuts.

## Related but separate

- **Invoice #170015** (409 PMs, 6/11–7/04) includes 143 rows imported from the pre-app tracking ("legacy") that have **no PDFs or photos in this system** — its backup must be assembled from the prior system's records. Handled separately, as agreed.
- **Freshpet Attachment 2** (SN#10961123 examples) arrived by email 2026-08-25. The Outlook attachment-extraction tool was down (pinned to a retired model — fixed in `skypace/Pacer-outlook` in this same change set); process it on receipt of the fix's deploy.

## Files in this folder

- `FINDINGS.md` — this document
- `defect-table.md` — every alleged (serial, store) pair vs. our records
- `visit-verification.csv` — all 196 reports: timestamps, photo status, contact, route context
- `reverification-units.csv` — the 47-unit re-verification worklist
- `freshpet-response-draft.md` — draft response language for Freshpet

## Addendum — the paperwork defect, measured (2026-09-01)

Asked directly: is the paperwork bad on the units we are sending someone back to,
and does it need refilling? The answer is that the paperwork weakness is **not
concentrated in the re-shoot list — it is uniform across the whole corpus**, and
the two defects are independent of each other.

Until PR #53 the app's `defaultForm()` pre-filled every reading and pre-ticked
every work box: `sp1 = 41°F`, `voltage = 120`, `intTemp = 38°F`, and all sixteen
checkboxes true. A report therefore carried a *measurement* only where the tech
actively changed something.

Across the 522 app-filed PM reports (the 143 legacy Bill Pace imports carry no
readings at all and are excluded):

| | reports |
|---|---|
| Byte-identical to the pre-filled default — no reading was ever entered | **451** (86%) |
| Show any edit at all | 61 |
| …of which the edit was the temperature alone | 58 |
| Voltage changed from `120` | **0 of 522** |
| A work box left unticked | **1 of 522** |
| A free-text comment added | 48 |

`voltage` reads exactly `120` on all 511 reports that carry one. Interior temp
reads `38°F` on 453 of 511. Neither is plausible as a measurement across 500+
outlets and cabinets.

Broken out by audit finding, the rate is flat:

| Audit finding | reports | pure default | |
|---|---|---|---|
| needs_plate_photo (the re-shoot list) | 166 | 137 | 82.5% |
| asset_list_confirm | 29 | 25 | 86.2% |
| no finding | 325 | 287 | 88.3% |

**So: yes, the paperwork should be refilled on the re-shoots — and it is, by
construction.** A re-shoot is a brand-new report filed on the current app, whose
`defaultForm()` now carries identity fields only. Readings start empty and the
submit gates (plate photo, interior temp, set point, working-on-arrival, store
signature or an explicit "no contact available") refuse a report without them.
Nothing extra had to be built for that.

Two things follow that are worth stating plainly:

1. **Re-shooting the 160 does not fix the other ~450.** The photo problem was
   concentrated; the paperwork problem is not. If Freshpet reads down the
   temperature column of any batch they will find `38°F` and `120V` repeating.
   That exposure is not addressed by the re-shoot programme and should not be
   presented as if it were.
2. **Voltage is now gated too** (2026-09-01), with an honest escape: a tech
   without a meter ticks "No meter on hand — voltage not measured" and the
   report prints *not measured (no meter)* rather than a number nobody read. A
   blank field and a fabricated reading are both worse than a stated gap.

## Addendum — signatures on a re-shoot (2026-09-01)

A re-shoot now starts from the **original report**, not a blank form. We were at
the store once and a manager signed for that visit; the re-shoot exists because
the photographs could not be stood behind, not because the visit was invented.
So the earlier answers come forward, the readings are retaken, and the store's
signature is **carried as a record of the original visit rather than collected
again** — nobody signs twice for one service call, and no manager is asked to
sign for readings taken on a day they were not shown.

The document says both things out loud: **ORIGINAL DATE** and **RESHOOT DATE**
side by side in the header, a banner naming what the document is, and an
attestation line under the signature block reading *"Signed on the original
visit of <date>. No store signature was taken on the re-shoot of <date> — the
readings and photographs above are attested to by the technician only."* The
customer portal shows the same two dates and the same sentence, so the web view
and the PDF cannot tell different stories.

Deliberately **not** carried forward: photographs (the whole point of going
back), and the readings — an inherited `38°F` is the original defect, so
`intTemp` / `sp1` / `voltage` start empty and are measured again. Audit
bookkeeping and the previous re-visit flags are dropped too.

### The signature graphic itself was never stored

Until this change a signature existed **nowhere but as pixels burned into the
PDF** — no column, no `form_data` key. New submissions now keep it on the
record (`form_data.storeSignature` / `techSignature`, behind RLS; never the
public photo buckets).

For the historical reports it is recoverable: `generatePDF` draws signatures at
a fixed rect (200 pt wide, ≤58 pt tall, x=40 store / x=326 technician), which
makes them identifiable rather than guessed at. A trial extraction over the 120
flagged reports that carry a store-contact name **recovered 116 store
signatures**; 3 have a contact name but no signature was ever drawn, and 1 PDF
failed to fetch.

**They were not backfilled, and that is a judgement call, not a limitation.**
Re-pasting a signature graphic onto a document the signer never saw is the same
shape as the defect this whole remediation is about — a photograph from one
visit reappearing on another report. The words carry the meaning; the ink adds
visual weight plus the risk of reading as an endorsement of readings taken
weeks later. The original PDF still holds the signature, Freshpet already has
it, and the portal links it. If the graphic is wanted on the re-shoot anyway,
the extraction is proven and the change is small — `original_signature` is
already rendered when present.
