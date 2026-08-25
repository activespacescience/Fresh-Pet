# Defect table — Freshpet allegations vs. our records

**How to read this:** Freshpet's reviewers read serial numbers off the serial-plate PHOTOS attached to the reports.
The "photographed serial" column is the serial Freshpet alleges; "our report(s)" shows what the report's serial FIELD
actually says at that store (always the asset-registry serial — the fields were never duplicated); the last column is
whether that store's report carries an image byte-identical (SHA-256) to an image on another report in the batch.

Where the photographed serial lives, per the asset registry:

| Photographed serial | Registry home |
|---|---|
| 278022 | PetSmart US #81 (Modesto) |
| 313084 | Petco #1343 (Sacramento) |
| 10157996 | Target #330 (Pleasant Hill) — PM'd in June, not in this batch |
| 10874841 | Save Mart #78 (Fresno) |
| 10961123 | Kelley's Pets #3465 (Fresno) |
| 11008872 | Food Maxx #453 (Bakersfield) |
| 11008876 | Food Maxx #453 (Bakersfield) — PM'd in June, not in this batch |
| M153303 | NOT in the asset registry — exists only inside reused photos |
| M158123 | NOT in the asset registry — exists only inside reused photos |

Category 3 items: Target #1384 / Walmart #3139 — byte-identical image confirmed on both (the "10% sales sticker" photo,
first uploaded on the Walmart #3139 report, 7/21). Reports with no serial-plate photo at all: 4 (listed in
reverification-units.csv).

Category 2 items (closed stores): see FINDINGS.md — all five visits are photo-documented; fields were app prefills.

| Photographed serial | Alleged at | Our report(s) at that store (report serial) | Reused image on that report? |
|---|---|---|---|
| 278022 | Lucky #750 | #589 S/N 80090400000116 | YES |
| 278022 | Target #938 | #573 S/N 10571802 | YES |
| 278022 | Save Mart #1 | #553 S/N 10567901; #556 S/N 10637908 | YES; YES |
| 313084 | Petco #1343 | #413 S/N 313084; #414 S/N 226512; #415 S/N 226507; #416 S/N 20125900000422 | no; no; no; YES |
| 313084 | Save Mart #622 | #411 S/N 10874906; #412 S/N 10911486 | no; no |
| 10157996 | Albertsons California #3364 | #447 S/N 10609622 | YES |
| 10157996 | Safeway #2263 | #423 S/N 310797 | YES |
| 10157996 | Petco #1343 | #413 S/N 313084; #414 S/N 226512; #415 S/N 226507; #416 S/N 20125900000422 | no; no; no; YES |
| 10874841 | Save Mart #635 | #538 S/N 11157328; #539 S/N 11157331 | no; no |
| 10874841 | Save Mart #78 | #536 S/N 10874913; #537 S/N 10874841 | YES; no |
| 10961123 | Raley's #339 | #574 S/N 10114978; #575 S/N 10114974 | YES; YES |
| 10961123 | Save Mart #95 | #568 S/N 10377426; #572 S/N 10874883 | no; YES |
| 10961123 | PetSmart US #1975 | #565 S/N 272477; #566 S/N 272479 Date 21- 10- 22; #567 S/N 272479; #571 S/N 278048 | no; no; no; YES |
| 10961123 | Walmart US #5710 | #569 S/N 10168520 | YES |
| 10961123 | Save Mart #1 | #553 S/N 10567901; #556 S/N 10637908 | YES; YES |
| 10961123 | PetSmart US #81 | #551 S/N 246419; #550 S/N 278022; #552 S/N 246414 | YES; no; no |
| 10961123 | Petco #1338 | #519 S/N 233671; #520 S/N 244380; #521 S/N 5232171; #522 S/N 341506031614; #523 S/N 312894 | no; no; YES; YES; YES |
| 10961123 | Kelley's Pets #3465 | #484 S/N 10961123; #485 S/N 10961123 | YES; YES |
| 11008872 | Walmart US #3141 | #479 S/N 290980 | YES |
| 11008872 | Walmart US #3140 | #469 S/N 302442 | YES |
| 11008872 | PetSmart US #3052 | #463 S/N 281232; #464 S/N 281224; #465 S/N M032630 | no; no; YES |
| 11008872 | Albertsons #3129 | #440 S/N 9407809; #441 S/N 10671490 | no; YES |
| 11008872 | Vons #1969 | #425 S/N 294053 | YES |
| 11008876 | Sam's Club #4819 | #446 S/N M155783 | YES |
| 11008876 | Target #2524 | #434 S/N 9632927 | YES |
| 11008876 | Albertsons #377 | #429 S/N 10663625; #430 S/N 10671487 | no; YES |
| 11008876 | Food Maxx #453 | #424 S/N 11008872 | YES |
| M153303 | Petco #307 | #548 S/N 202406; #549 S/N 243062; #559 S/N 313166 | no; no; YES |
| M153303 | Safeway Northern California #1661 | #542 S/N 295380; #543 S/N 295403 | no; YES |
| M153303 | Save Mart #78 | #536 S/N 10874913; #537 S/N 10874841 | YES; no |
| M153303 | Petco #1338 | #519 S/N 233671; #520 S/N 244380; #521 S/N 5232171; #522 S/N 341506031614; #523 S/N 312894 | no; no; YES; YES; YES |
| M153303 | Walmart US #1815 | #515 S/N 9697100 | YES |
| M158123 | Safeway Northern California #2856 | #600 S/N 294043 | YES |
| M158123 | Walmart US #2161 | #593 S/N 302431 | YES |
| M158123 | Raley's #339 | #574 S/N 10114978; #575 S/N 10114974 | YES; YES |
| M158123 | Carters Pet Mart #56789 | #544 S/N 9723510; #545 S/N 9637980 | no; YES |
| M158123 | Save Mart #71 | #533 S/N 10372249; #534 S/N 11157343 | YES; no |
| M158123 | Petco #1338 | #519 S/N 233671; #520 S/N 244380; #521 S/N 5232171; #522 S/N 341506031614; #523 S/N 312894 | no; no; YES; YES; YES |
| M158123 | Target #1417 | #502 S/N 10540856; #503 S/N 10902793 | YES; YES |
