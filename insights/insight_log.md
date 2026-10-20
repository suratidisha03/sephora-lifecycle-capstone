# Stage 3 Insight Log — DRAFT (2026-10-09)

**Status: human check done (2026-10-09). Disha agreed with 14 of 20 checked codes (70%); 6 corrected, and a new code T13 (routine/layering problem) was added. Q1-Q4 were Disha's own judgment; Q5-Q20 were AI-recommended, then reviewed and accepted by Disha. Still to do: run sql/08 to confirm the full-sample keyword counts.**

Evidence base: public_reviews (9,999 reviews, 3 products, 3,333 most recent each). Hand-coded sample: 150 reviews (per product, the 30 most recent 1-2 star and 20 most recent 4-5 star). Coded sample is mostly 2022-2023, so it describes recent reviewers. Reviewers are a self-selected sample; nothing here measures sales, conversion or skin outcomes.

## Context: the products are not on equal time windows
| Product | Mean rating (all retained) | Mean rating (shared period 2019-08-23 to 2023-03-21) | % recommend, of those who answered (shared period) |
|---|---|---|---|
| P7880 fresh Soy cleanser | 4.28 (n=3,333) | 4.19 (n=1,439) | 79.6% |
| P248407 First Aid Beauty Ultra Repair Cream | 4.41 (n=3,333) | 4.15 (n=1,095) | 77.8% |
| P427421 Drunk Elephant Protini | 3.84 (n=3,333) | 3.84 (n=3,333) | 69.8% |

First Aid Beauty's lead shrinks in the shared period because its older reviews (2016-2018) are more positive. Compare products on the shared period.

---

## Observation 1 — First Aid Beauty: pilling complaints grew in recent low reviews
| | |
|---|---|
| Observation | In the 30 most recent 1-2 star reviews, 9 describe texture problems (7 name pilling outright) and 2 more say it pills or curdles only when layered over serums or retinol (routine/layering, T13); 9 report breakouts or clogged pores; 6 say the formula seems to have changed. Across all retained low reviews, "pill" appears in about 2% per year in 2016-2020, then 12% (2021), 18% (2022) and 28% (2023). |
| Evidence | insights/coded_sample.csv (P248407-L-01 to L-30); sql/08 Q1; denominators: 30 coded low reviews; 340 low reviews total (25 mention "pill") |
| Proposed action | Add a layering and application guide ("thin layer, let serums dry first, press don't rub"), since part of the pilling is reported only on top of other products, to the product page and day-2 welcome email for moisturizer buyers |
| Limit | Recent low-review sample only; small yearly counts (25-54 low reviews per year); cannot verify any formula change; does not prove pilling affects sales |
| Next test | A/B the product page with vs without the application guide; outcome = guide clicks and add-to-cart in the simulated data / test site |

## Observation 2 — fresh Soy cleanser: scent and makeup removal split opinion
| | |
|---|---|
| Observation | Scent is the most frequent theme in recent low reviews (13 of 30), described as pickle, sour or plastic-like; 3 suspect a change. But 6 of 20 recent high reviews praise the scent. Cleansing/makeup removal is also split: 8 of 30 low reviews say it cleans poorly or does not remove makeup, while 7 of 20 high reviews praise makeup removal. Across all reviews, scent is mentioned at the same rate in low (39%) and high (40%) reviews, and most often in 3-star reviews (134 of 255, 53%), which suggests scent is a deciding factor for undecided buyers. |
| Evidence | coded_sample.csv (P7880-L, P7880-H); sql/08 Q2; denominators: 30 low and 20 high coded; 383 low and 2,695 high total |
| Proposed action | Expectation-setting copy: describe the scent plainly, say it is a low-lather gel, and say what makeup it removes (light makeup; suggest a first cleanse for heavy makeup). Offer a "try the mini first" path |
| Limit | Scent is subjective; keyword counts include positive and negative mentions; 3 of 30 low reviews came from free samples |
| Next test | A/B product description with vs without the scent and lather details; outcome = add-to-cart and mini-size selection in the test site |

## Observation 3 — Drunk Elephant Protini: price is discussed by fans and critics alike
| | |
|---|---|
| Observation | 8 of 30 recent low reviews question the price or value, and 5 of 20 recent high reviews still name price as the downside. Breakouts are the most common low-review theme (11 of 30), and 5 of 30 mention social-media hype. Across all reviews, price/value words appear in 34% of low and 31% of high reviews. |
| Evidence | coded_sample.csv (P427421-L, P427421-H); sql/08 Q3; denominators: 30 low and 20 high coded; 721 low and 2,219 high total |
| Proposed action | Value-framing content: how many weeks a jar lasts at a typical amount, plus a patch-test tip in the welcome email for first-time buyers |
| Limit | Price keywords include positive "worth it"; breakout reports are self-reported and not causal; hype mentions may reflect the 2020-2021 review spike |
| Next test | A/B a "cost per week" message vs none in a welcome email; outcome = click rate in Mailchimp test sends / simulated email data |

---

## What these do NOT show
- No sales, conversion, return or CAC figures (the data has none).
- No clinical effects. Breakouts and irritation are what reviewers reported, not proven causes.
- Not representative of all Sephora shoppers.
