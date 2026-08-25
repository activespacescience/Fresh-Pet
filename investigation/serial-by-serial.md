# Serial-by-serial: do we have the photos, do we have the paperwork?

**Method (2026-08-25):** every photo on every report at every store Freshpet named (64 reports, 124 photos, 37 stores) was opened and read — the serial printed on any visible plate was transcribed and compared to the report's serial field, on top of the earlier byte-level (SHA-256) reuse analysis. This is the complete answer, not a sample.

**Paperwork first, because it's the short answer:** all 64 reports have a signed checklist PDF, a signed-at timestamp, and (except five: #411, #412, #416, #446, #567) a named store contact. The paperwork exists everywhere. **The photo evidence is the broken leg** — and it breaks three ways:

| Bucket | Reports | Meaning |
|---|---|---|
| **CLEAN** | 13 | The report's own photo shows its own unit's plate. Nothing to do. |
| **RELABEL** | 13 | Photo shows the wrong plate — but this unit's correct plate photo **already exists on another report in our storage**. Fix from the office; no site visit. |
| **RE-SHOOT** | 38 + 2 no-photo | No plate photo of this unit exists anywhere in the batch. Recover from the tech's camera roll or photograph on site. |

Machine-readable version: [`recovery-worklist.csv`](recovery-worklist.csv).

---

## The nine serials Freshpet flagged

Read this as: the serial they flagged is what's printed on a *photo*; the "true home" is where our asset registry (their asset list) puts that unit.

### SN 278022 — true home: PetSmart US #81, Modesto
- Its plate photo appears on **Save Mart #1 (#556), Target #938 (#573), Lucky #750 (#589)** — all wrong; those three units need their own plate shots (RE-SHOOT).
- Its own home report **#550 shows the wrong plate too** (313166 — Petco #307's unit). But since the 278022 plate is on file (three copies!), #550 is a RELABEL: move the plate photo home.

### SN 313084 — true home: Petco #1343, Sacramento
- Home report **#413 is CLEAN** (own plate, unique photos).
- A *second, distinct shot* of the same plate sits on **Save Mart #622 #411** — that store's unit (10874906) has no photo of its own: RE-SHOOT. Sibling #412 (10911486) has **zero photos**: RE-SHOOT.
- Bonus finding at Petco #1343: sibling reports **#414/#415 have each other's plates** (226507↔226512 swapped) — RELABEL both; and **#416's photo shows 10157996** (Target #330's unit): RE-SHOOT 20125900000422.

### SN 10157996 — true home: Target #330, Pleasant Hill (PM'd in June, clean, outside this batch)
- Its plate appears on **Safeway #2263 (#423), Albertsons California #3364 (#447), Petco #1343 (#416)**. All three RE-SHOOT (310797, 10609622, 20125900000422).

### SN 10874841 — true home: Save Mart #78, Fresno
- Home report **#537 is CLEAN**.
- A separate shot of the same plate sits on **Save Mart #635 #538**; and #635's other report **#539 shows 10874913 — Save Mart #78's OTHER unit**. Both SM #635 units (11157328, 11157331): RE-SHOOT. SM #78's #536 (10874913) is a RELABEL — its plate is on #539.
- ⚠ Registry check during the visit: the SM #78 ↔ SM #635 plates are crossed enough that the asset list's unit placement between these two Fresno stores should be confirmed on site.

### SN 10961123 — true home: Kelley's Pets #3465, Fresno
- Home reports **#484/#485 both show the correct plate** — but they are a **double submission of the same unit** (76 s apart). Keep one, void/credit the other ($30).
- Its plate rode onto **7 other stores' reports**: PetSmart #81 (#551), Save Mart #1 (#553), Walmart #5710 (#569), PetSmart #1975 (#571), Save Mart #95 (#572), Petco #1338 (#523), Raley's #339 (#575). #571 and #572 are RELABELs (their units' plates exist on sibling reports); the rest RE-SHOOT.

### SN 11008872 — true home: Food Maxx #453, Bakersfield
- Its plate appears on **Vons #1969, Target #2524, Albertsons #3129, PetSmart #3052, Walmart #3140, Walmart #3141** — the exact Freshpet list. All those units: RE-SHOOT (except PetSmart #3052's M032630, whose plate is on sibling #463 → RELABEL).
- Home report **#424's photo shows the sibling unit 11008876** — so both Food Maxx units ARE documented, just crossed: RELABEL #424.

### SN 11008876 — second Food Maxx #453 unit (June PM)
- Its plate rode onto **Albertsons #377 (#430), Sam's Club #4819 (#446), Target #2524 (#434), Petco #1338 (#521)** and Food Maxx's #424. RE-SHOOT the hosts' own units (10671487 + the no-photo 10663625, M155783, 9632927, 5232171).

### SN M153303 — **not on the asset list; a real unlisted unit somewhere**
- Photographed onto **Walmart #1815, Petco #1338 (#522), Save Mart #78 (#536), Safeway #1661 (#543), Petco #307 (#559)**. All five hosts' units: RE-SHOOT or RELABEL (see worklist). Whichever store the re-verification finds actually hosting plate M153303 gets reported to Freshpet as an asset-list correction (or a field-added asset we can bill).

### SN M158123 — **not on the asset list; a real unlisted unit somewhere**
- The most-traveled plate: **Target #1417 (both #502/#503), Petco #1338 (#521), Save Mart #71 (#533), Carters #56789 (#545), Raley's #339 (#574), Walmart #2161 (#593), Safeway #2856 (#600)**. Same treatment as M153303. Note Target #1417's "two reports, same serial" is actually two different units (10540856, 10902793) whose reports shared identical photo sets — both RE-SHOOT.

### Category 3 stores (no serial alleged, photo issues)
- **Target #1384 (#453) / Walmart #3139 (#452)**: share a byte-identical equipment image ("10% sticker"); neither has any plate photo → both RE-SHOOT.
- **Save Mart #54 (#508) / Save Mart #92 (#527)**: photos are equipment-only, no plates legible, no byte-level sharing detected between them → both RE-SHOOT (and ask Freshpet which images they matched).

---

## How to fix it — in cost order

**1. Office relabels — today, no travel (13 reports).** The correct plate photo is already in our storage, just filed on the wrong report. Reopen each report and move the image to where it belongs (the new duplicate-photo guard enforces move-not-copy, and every edit is timestamped as a modification): #414, #415, #424, #465, #533, #536, #545, #548, #550, #559, #567, #571, #572.

**2. The tech's camera roll — this week, before rolling a truck.** Every misplaced image was picked off the device gallery, so the *originals live on Michael's phone with native EXIF timestamps and GPS intact* (the app strips EXIF; the phone doesn't). Export the full camera roll for 7/15–7/31, preserve it untouched, and match capture times against the route order in `visit-verification.csv`. Any store-correct plate shots found there close RE-SHOOT items with **better** evidence than we ever had — and the export doubles as independent proof-of-presence for the whole route.

**3. On-site re-shoots — whatever the camera roll doesn't cover (≤40 units, 31 stores).** Under the new controls (camera-only plate photo, hash-checked, required to submit): Fresno/Ceres, Modesto, Bakersfield, Sacramento, Tri-Valley clusters — roughly four route days. While there: identify which stores actually host plates M153303 and M158123.

**4. Registry & billing corrections.**
- Credit one of the two **Kelley's Pets #3465** PMs (double submission).
- **PetSmart US #1975**: asset rows `272479` and `272479 Date 21- 10- 22` are one physical unit (a garbage CSV import row) — merge the rows, credit one of the two PMs billed against it. The store likely has 3 units, not 4.
- Confirm unit placement between **Save Mart #78 / #635**, and the true homes of **M153303 / M158123**; send Freshpet the asset-list corrections along with the five closed/missing sites.

**Net effect on the Freshpet response:** we can honestly say every flagged report has signed, timestamped paperwork; 13 of the flagged units were correctly photographed all along (mislabeled, now fixed from existing evidence); ~40 get fresh plate photos at no cost; and two over-billed PMs (~$60) are credited proactively — which buys credibility for the much larger amount we're defending.
