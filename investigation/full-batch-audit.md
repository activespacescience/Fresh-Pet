# Full-batch evidence audit — every report, every photo, every signature

**Method (2026-08-25):** all 196 report PDFs on invoice #172825 verified in storage and their embedded
signature images cryptographically compared; all 392 attached photographs individually read, the plate
serial in each transcribed and compared to the report's serial field and the asset registry.
Row-by-row results: [`master-evidence-audit.csv`](master-evidence-audit.csv).

## Signatures / paperwork
- **196/196 PDFs exist**, all carrying the on-device completion timestamp.
- 195 carry the tech signature (missing: #446 Sam's Club #4819); 194 carry a store-side signature
  (missing: #477 Food Maxx #413, #565 PetSmart #1975).
- **No signature image is shared between any two reports** — every signature was drawn fresh.

## Photos (196 reports)
| Finding | Reports | Path |
|---|---|---|
| VERIFIED — own plate on own report | **68** | evidence stands |
| SWAPPED WITH SIBLING — unit photographed at the store, label crossed | **50** | reissue from file |
| MISFILED CROSS-STORE — plate photo on another store's report | **10** | reissue from file |
| PLATE≠ASSET LIST — unique on-site shot, serial not on the list | **13** | likely stale asset list; confirm |
| WRONG PLATE, unit undocumented | **38** | camera roll → re-shoot |
| NO LEGIBLE PLATE | **8** | camera roll → re-shoot |
| NO PHOTOS | **4** (#412, #429, #445, #493) | camera roll → re-shoot |
| SITE EXCEPTION (closed/missing) | **5** | withdraw as PM |

## Store level (129 stores)
44 fully verified as-is · 20 with every unit photographed but labels crossed (office fix) ·
11 pending asset-list serial confirmation · 49 needing field recovery for ≥1 unit · 5 closed/missing.
After the office relabels, **64 stores carry complete signed-report + matching-photo evidence with zero field work**.

## New store-level discovery: sibling swaps are batch-wide
Beyond the stores Freshpet flagged, ~25 additional two-unit stores have their two plate photos crossed
between sibling reports (e.g. Vons #2420, Petco #1306, Albertsons #336/#358/#1398, Save Mart #93/#96/#651/#86,
Food Maxx #403/#413/#414/#456, PetSmart #82/#86/#2487, Foods Co #365/#384, Vons #1754/#2033, Lucky #744).
The tech photographed both units, then attached them in the wrong order — fully recoverable from file.

## Extra units observed (possible unlisted / billable assets)
Plates photographed on site matching nothing on the asset list: 10213740 (Walmart #1972), 11351592
(Walmart #1624), 11200214 (Walmart #5632), 10571808 (Walmart #2985), 304968 dup at Safeway #9, plus the
known M153303 / M158123. Costco #146/#661 units photographed as M2502943 / M2503082 vs list serials
107021xx — likely replaced units. Lunardis #9 and several others read differently from the list —
all listed under PLATE≠ASSET LIST in the CSV.

The Freshpet-facing package built from this audit: `Freshpet-Invoice-172825-Findings.pdf` (22 pp,
full per-report appendix).
