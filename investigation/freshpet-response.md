# Response to the invoice #172825 PM report review

**Prepared:** 2026-08-28 · Alameda Point Beverage Group / FreeFlow Beverage Solutions

---

## Summary

Your review was correct. We investigated every report in the submission — and then went
further, auditing every PM report our app has ever produced (592 reports across June, July
and August). What we found was a defect in the application we piloted this summer, not a
dispute about your findings. This document answers each of your three items with what we
found, what we have corrected, and what we are still working on.

We are not asking you to accept documentation we cannot stand behind. Where a report's
photographic evidence cannot be trusted, we have removed it and scheduled the unit to be
serviced and photographed again at our cost.

---

## Item 1 — The same serial number appearing at multiple locations

**Your finding is confirmed.** We reproduced every example you listed.

**Root cause.** The field app allowed a technician to attach photographs from the phone's
photo gallery rather than requiring the camera. Paperwork was frequently completed in a
batch at the end of a route rather than at each store — in the worst case we measured,
reports for different stores were submitted 28 seconds apart. When photographs are chosen
from a gallery under those conditions, the wrong image is easy to pick and nothing in the
app objected. The application also stripped image metadata when it re-encoded photos, so
there was no automatic check that could have caught it.

This is our software's failure. It is not evidence that the visits did not happen, and we
address that separately below — but we understand why the documentation, as submitted,
could not be relied on.

**What we corrected.**

| Action | Count |
|---|---|
| Serial-plate photographs traced back to the unit they actually show and reattached to the correct report | 144 |
| Reports from which a photograph of ANOTHER unit was removed | 73 |
| Photographs removed because they documented a different unit | 76 |
| Reports reissued with corrected photo pages and a visible correction stamp | 217 |

**Verified result.** We re-checked every photograph in the system after the correction.
Eight of the nine serials you listed now appear on exactly one report — the report for the
unit that plate actually belongs to. Two of them (M153303 and M158123) turned out not to
match any unit on your asset list at all and no longer appear on any report.

The ninth, **S/N 10961123**, still appears on two reports — and that is the Kelley's Pets
#3465 duplicate you identified yourself. Both reports are for the same single unit, so the
plate photograph is correct on both; the problem there is the duplicate submission, not the
photograph. That report is flagged for credit.

Corpus-wide, only three serials now appear on more than one report, and in every case it is
the same physical unit with more than one report filed against it — the duplicate-submission
issue, which we address below. **No photograph of one store's unit is presented as
documentation of another store's unit anywhere in the system.**

Nothing was deleted: the original submission is preserved on every record, and each
corrected report carries a stamp explaining what changed and why.

**Where a report lost its evidence, we say so.** Six reports had every photograph removed
because every one showed a different unit. Those reports now state plainly that no
photograph documenting the unit exists, and the units are scheduled for a re-visit.

## Item 2 — PM reports submitted for closed stores and missing units

**Your finding is confirmed, and these have been withdrawn as billable work.**

| Location | What the technician found | Status |
|---|---|---|
| Walmart US #1983 | Store permanently closed, boarded up | Withdrawn — site visit exception |
| Foods Co #784 | Store closed, CLOSED signage posted | Withdrawn — site visit exception |
| Comptons Market #14696 | No Freshpet unit found at the address | Withdrawn — site visit exception |
| Incredible Pets #24012404 | Address is no longer this business | Withdrawn — site visit exception |
| Murphys Paw #1910 | Store open; listed unit not on site | Withdrawn — site visit exception |

**On the completed inspection data and signatures.** We investigated this specifically,
because it was the most serious thing in your letter. The visits were real — the
technician drove to each address, and in each case photographed what he found, including
the boarded-up storefront at Walmart #1983 and the CLOSED signage at Foods Co #784.

The completed checklist fields came from our form, not from the technician. The app
pre-filled the inspection checkboxes with default values and offered no way to record
"I arrived and there was nothing here." Faced with a form that would not submit otherwise,
he completed it and wrote what he actually found in the comments. That is a design failure
on our part that produced a document which misrepresents the visit, and we are not going to
defend the document. We are telling you how it came to exist.

**The fix is shipped.** The app now has a "Site Visit Exception" path: a technician records
a closed store or a missing unit with a photograph and no inspection data at all. These can
never be invoiced — the block is enforced both in the app and in our billing system, so a
site visit exception cannot reach an invoice even by mistake.

## Item 3 — Missing serial-plate photographs and reused equipment images

**Your finding is confirmed.** Target #1384, Walmart #3139, Save Mart #92 and Save Mart #54
all lack a serial-plate photograph, and the shared equipment image you identified — the one
carrying a 10% sales sticker belonging to neither store — is exactly the defect described in
Item 1.

We audited every photograph in the system rather than only the examples you found. Across
all three months, after recovering every photograph that could be matched back to its
correct unit, **196 reports still have no photograph showing their own unit's serial plate.**

We are not asking you to pay for undocumented work. Our proposal is in the next section.

---

## What we are doing about it

**1. Re-visits, at our cost.** Every unit without trustworthy documentation is being
serviced and photographed again. We have built a re-visit workflow into the app: the
affected report's photographic evidence is disconnected, the stop returns to the
technician's route flagged for a redo, and the unit is documented properly. We will supply
the new reports as they are completed.

**2. The defect is fixed.** These changes are live:

- Photographs can only come from the camera. The gallery option is gone.
- A photograph of the serial plate is **required** before a report can be submitted.
- Every photograph is fingerprinted on upload. An image already used on another report is
  refused at the point of capture, with an explanation.
- The form no longer pre-fills inspection answers. The technician enters what he observes.
- Site Visit Exception, described above, with a hard block on invoicing.
- One report per unit per day, which prevents the duplicate submissions you noted.

**3. Duplicate submissions.** You are right about Kelley's Pets #3465 — one unit, two
reports. The duplicate is flagged for credit. Our own audit found the same pattern
elsewhere and we are raising it rather than waiting to be asked: on invoice **#170015**
(June), 17 units received two or more reports, 19 extra reports in total. The cause was the
same retry behaviour — a technician who was not sure a submission had gone through pressed
submit again. The app now refuses more than one report per unit per day. We will provide the
list and expect to credit these.

**4. A full audit trail.** Every corrected record carries a note stating what was changed,
when, and why, with the original submission preserved. We can supply this record for any
report you want to examine.

---

## What we would like to ask of you

**Asset list reconciliation.** During the audit we found the opposite problem in several
places: locations where our technician documented **more units on site than the asset list
carries**. At three stores this is recorded on a paper checklist signed by store staff —
Walmart #5632 and Walmart #1972 both carry a store employee's signature attesting that two
assets are present where the list shows one. In a further 20 cases, a plate photograph at a
store your list shows as single-unit reads a serial that is not on the list.

We are not billing for these and we are not asking you to accept our count. We would like
to reconcile the list with you, because it affects both of us: if a second unit exists and
is not on the list, it is not being maintained.

We have prepared this as a separate schedule and can send it whenever you would like it.
