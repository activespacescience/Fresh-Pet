# Draft response to Freshpet — invoice #172825 review

> Status: DRAFT for Sky's review. Nothing here concedes the 95-report payment position.
> Audience assumption: may be read beyond our direct contact.

## One-paragraph root cause (plain language)

Our investigation confirms your reviewers' observations and identifies a single root cause behind the duplicate serial numbers, reused photos, and misfiled images: the reporting tool we piloted for this batch allowed technicians to attach photos from the device's photo gallery with no link between an image and the specific unit it documents, no duplicate-image detection, and no requirement that a serial-plate photo be present. During end-of-route report entry, a small set of photos was attached repeatedly across reports — the "duplicate serials" your team caught are the serials visible in those reused plate photos, while the serial numbers recorded on the reports themselves match your asset list for each store and were never duplicated. The five closed-store reports have a related cause: the tool offered no way to report a closed store or missing unit, so those visits — which did occur, and are photo-documented (our technician photographed the boarded-up Walmart and the CLOSED signs at Foods Co on arrival) — were forced through a standard PM form whose temperature fields were pre-populated defaults. We have rebuilt the tool so that none of this is possible again, and we will re-verify every affected unit on site at no cost to Freshpet.

## Structure of the full response

1. **Findings, category by category** — from `FINDINGS.md`: photo-reuse mechanism (Cats 1/3/4), closed-store mechanism (Cat 2), with the defect table attached.
2. **What did not happen** — visits were not fabricated: 149 of 196 reports carry photo evidence unique in the batch; submission telemetry traces coherent daily routes (Sacramento 7/15, Bakersfield 7/20–21, Fresno 7/22–23, Modesto 7/24 & 7/29, Tri-Valley 7/30–31); 182 reports carry a named store contact. The closed-store visits are proven by the tech's own photos of the closures.
3. **Corrective actions, already deployed** — required camera-captured serial-plate photo on every PM; cryptographic duplicate-photo rejection; no pre-filled readings; a dedicated "store closed / unit missing" report type that cannot be invoiced as a PM; one-report-per-unit-per-day; explicit "no store contact available" state instead of a signature box that must be filled.
4. **Re-verification offer** — the 47 units whose photo evidence was compromised (list attached) re-photographed under the new controls within [2 weeks], at no cost. The five closed/missing sites returned as asset-list corrections.
5. **Payment position** — we ask Freshpet to review the corrected evidence package rather than reduce payment to the 95 reports: the service was performed; the documentation tool failed it. We also ask for Freshpet's full 196-report itemization (95 + 67 accounts for 162) so both sides reconcile the same list.
6. **Invoice #170015** — backup being assembled separately from the prior tracking system's records, as discussed.

## Asks of Freshpet

- Full itemized disposition of all 196 reports (which 95 validated, which flagged, which unnoted).
- Confirmation of the five closed/missing sites for removal from the PM asset list, and agreement on trip-charge treatment for stops that turn out closed.
- A 2-week window to deliver the re-verification package before any payment adjustment is finalized.
