# GA4 Tracking Spec (Stage 5, guide p.14-15)

**GTM container:** GTM-5GBKDSDX (installed in index.html and guide.html 2026-10-13).
**GA4 property:** Routine Guide DEMO (test), stream "Demo site", Measurement ID G-84Y4B5ERNJ (created 2026-10-13).

**Status:** events built into the demo page's data layer and tested in a browser (2026-10-13, automated test). **GTM and GA4 not yet connected** (needs Disha's Google sign-in). Do not claim "implemented GA4 tracking" until GTM Preview and DebugView screenshots exist.

## Events
| Event | Trigger on the demo page | Parameters sent | Never sent |
|---|---|---|---|
| view_item | "Details" opened on a product | currency USD; value; items[ item_id, item_name, item_brand, item_category, price, quantity ] | |
| select_content | "If it pills: tips to try" opened (First Aid Beauty) | content_type = layering_tips; content_id = P248407 | |
| add_to_cart | "Add to bag" clicked (card or details) | currency; value (that item); items (that item, quantity 1) | |
| begin_checkout | "Checkout (demo)" clicked with a non-empty bag | currency; value (bag total); items (whole bag) | |
| purchase | "Place demo order" clicked | transaction_id (DEMO-yyyymmddhhmmss-XXXX); currency; value; items | Payment data (none collected) |
| sign_up | Valid email submitted in the demo form | method = demo_form | The email address (never stored, sent or pushed) |

**Rules built in:** `{ecommerce: null}` is pushed before each e-commerce event (Google's recommendation); purchase has a unique transaction_id and two guards against double firing (button lock + list of fired IDs); the email field is cleared and never enters the data layer.

**Test vs synthetic data:** test events are dated October 2026 and carry DEMO- transaction IDs. The Stage 6 synthetic dataset covers Jan to Jun 2026. Keep them separate in every report.

## UTM rules (lower case, stable)
- Organic social test links: `?utm_source=instagram&utm_medium=social&utm_campaign=routine_launch_2026&utm_content=post_a_two_steps` (and `post_b_know_before`)
- Simulated paid (Stage 6 data only): `utm_source=google&utm_medium=cpc&utm_campaign=sim_search_jan2026`; `utm_source=meta&utm_medium=paid_social&utm_campaign=sim_social_jan2026`

## Page test results (2026-10-13, Playwright, before GTM)
| Check | Result |
|---|---|
| Event order in a full journey | view_item, select_content, add_to_cart ×2, begin_checkout, purchase, sign_up |
| purchase fires once on a double-click | Yes (1) |
| purchase fires again on a later extra click | No (still 1) |
| purchase payload | transaction_id DEMO-…; value 81.00 for 2 items; items listed |
| Invalid email shows error message | Yes |
| Email appears anywhere in the data layer | No |
| Keyboard only: Tab to "Details", Enter opens, Escape closes | Yes |
| Mobile 390 px: horizontal scroll | None |
| JavaScript errors | None |
Screenshots: tracking/screenshots_page_tests/

## GTM build and Preview results (2026-10-13)

| Item | Setting |
|---|---|
| Tag: GA4 - Google tag | Google Analytics (Google tag), G-84Y4B5ERNJ, trigger Initialization - All Pages |
| Trigger: CE - demo events | Custom Event, regex `view_item\|add_to_cart\|begin_checkout\|purchase\|sign_up\|select_content`, all custom events |
| Tag: GA4 - Event - demo | GA4 Event, G-84Y4B5ERNJ, event name `{{Event}}`, Send Ecommerce data = Data Layer, trigger CE - demo events |

Preview (Tag Assistant) result: Google tag fired 1 time; event tag fired 18 times across all 6 event types; Tags Not Fired: None. Purchase data layer: transaction_id DEMO-20261014014004-HXOE, value 429 USD (11 x $39), item P7880. Evidence: `screenshots_gtm/`.

Known limitation: `method` and `content_type` parameters are not mapped to GA4 event parameters. Event counts are unaffected.

Open issue QA-21: Add to bag has no visible confirmation, so the tester clicked 11 times.
