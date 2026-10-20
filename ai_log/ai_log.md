# AI Revision Log

One entry per task where AI helped. Never mark an output as verified without running or checking it yourself.

## Entry template
- **Date:**
- **Stage:**
- **Task:**
- **Prompt (short version):**
- **AI draft (file or summary):**
- **Error or issue found:**
- **Correction made:**
- **Final check (how I verified it):**

## Entry 1
- **Date:** 2026-10-09
- **Stage:** 3
- **Task:** Draft a theme rubric and code a 150-review sample
- **Prompt (short version):** Propose a rubric from the sample; code supplied rows only; flag ambiguity; cite row IDs; no invented counts
- **AI draft:** insights/theme_rubric.md, insights/coded_sample.csv, insights/theme_tally.csv, insights/insight_log.md (draft)
- **Error or issue found:** First keyword-only attempt was too noisy (e.g. "red" and "no irritation" counted as irritation), so it was dropped in favor of reading and hand-coding the sample; keywords kept only as a rough cross-check (sql/08)
- **Correction made:** Coded by reading each review; 12 ambiguous rows flagged with reasons
- **Final check (how I verified it):** Disha checked 20 coded rows (insights/verification_sheet.csv) on 2026-10-09. Agreement 14 of 20 (70%). Errors found: missed breakouts in an "enlarged pores" review; pilling caused by layering wrongly coded as product texture (2 rows plus 1 burn-with-acne-treatment row); scent defense coded as complaint; vague "didn't work" coded as cleansing. All 6 fixed in coded_sample.csv (original codes kept in codes_original); new code T13 added to the rubric. Q1-Q4 decided by Disha; Q5-Q20 AI-recommended and accepted by Disha.

## Entry 2
- **Date:** 2026-10-12
- **Stage:** 4
- **Task:** Verify product facts; draft SEO plan, acquisition map and copy deck (A/B per asset)
- **Prompt (short version):** Use pages 11-13 and verified product facts; original wording; no invented reviews, search volumes or efficacy claims
- **AI draft:** copywriting/product_facts.md, acquisition/seo_plan.md, acquisition/acquisition_map.csv, copywriting/copy_deck.md
- **Error or issue found:** Planned "cost per week" copy for Protini would have needed an invented usage amount; dropped. Protini's listed skin types exclude dry skin, so copy had to state that. First Aid Beauty is labeled fragrance free but lists eucalyptus oil, so "no essential oils" was ruled out.
- **Correction made:** Logged in product_facts.md "Facts we do NOT have"
- **Final check (how I verified it):** PENDING. Disha chooses A or B for each asset and edits the wording.
- **Additional error found (2026-10-12, Disha's "make sure nothing is random" check):** six pilling lines promised a fix that review evidence contradicts (L-04, L-17, L-22). Rewritten to suggest, not promise. Every final line now traced to a source in copywriting/traceability.md.

## Entry 3
- **Date:** 2026-10-12
- **Stage:** 4 (email design; templates are built and test-sent in Stage 7)
- **Task:** Compare email styles, write the remaining lifecycle email drafts, and choose final templates
- **Prompt (short version):** Show A, B and C as full 7-email threads; replace beige/tan colors that read as AI; borrow a real Sephora promo email's layout for our own brand; facts only from product_facts.md; suggest, never promise
- **AI draft:** emails/options/email_thread_style_A to D; emails/final/ (EM-01 to EM-07 and the full thread); body copy for EM-01 (redesigned personal note), EM-02 and EM-04 to EM-07 is new AI draft copy
- **Error or issue found:** (1) EM-02 headline "Pilling is one of the most common complaints about rich creams" was an unsupported frequency claim. (2) EM-04 line "the one thing reviewers wish they'd known first" overstated the evidence. (3) Style D's hero showed internal labels ("EM-01 · DAY 0") that a customer would see. (4) Copying Sephora's format too closely (points, Beauty Insider Cash, promo codes) would have invented loyalty records and offers. (5) The earlier EM-01 file was still marked "copy final" after the template changed. (6) EM-01 said "I read through thousands of reviews", which overstated the method (150 reviews hand-coded, the rest counted in SQL).
- **Correction made:** (1) Rewritten to "Why some creams pill, and what may help". (2) Rewritten to "Here's one thing worth knowing before you buy". (3) Labels removed. (4) Kept only the layout (top bar, wordmark, nav, hero, grid, footer); no points, discounts or codes. (5) EM-01_welcome_1.md marked superseded. (6) Rewritten to "I analyzed thousands of reviews" in every file. New body lines added to copywriting/traceability.md.
- **Final check (how I verified it):** Facts checked against product_facts.md (prices, mini sizes, skin types, scent). Searched final files for em dashes (none). PENDING: Disha reads EM-02 and EM-04 to EM-07 and approves or edits; Disha picks subjects in copy_deck.md.
