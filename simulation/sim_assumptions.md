# Stage 6 Simulation Assumptions (FINAL, v1, 2026-10-14)

Evidence layer: **Simulated.** Nothing here describes real Sephora performance or real business results.
Script: `simulation/generate_sim_data.py` (seed 42). Running it twice gives byte-identical files (checked by MD5).
Volume decision: **Option B**, approved by Disha on 2026-10-14. 40,000 sessions, so the visit-to-order rate is about 3%, not the 20% implied by the guide's 6,000 sessions.

## A. Fixed by the brief
- Period: Jan 1 to Jun 30, 2026 (181 days).
- Paid spend: $3,000 total, all on Jan 1 to 30. Search $1,800, social $1,200. $0 on the other 151 days.
- Seed: 42. Tables are prefixed `sim_`.

## B. Sourced inputs
| Input | Value | Source |
|---|---|---|
| Search CTR, CPM, click-to-purchase rate | 1.61%, $18.38, 4.33% | Triple Whale Google Ads benchmarks, Beauty median, Aug 2025 to Jul 2026 |
| Social CTR, click-to-purchase rate | 2.46%, 1.79% | Triple Whale Facebook Ads benchmarks, Beauty median, Aug 2025 to Jul 2026 |
| Social CPM | $18.38 (stand-in) | **No published Meta beauty CPM, so the Google figure is reused. Flagged as a limit** |
| Email click rate | 2% of delivered | Mailchimp benchmarks (Dec 2023): 2.62% all users, 1.74% e-commerce |
| Product prices | $39 / $42 / $72 | product_facts.md (sephora.com, checked 2026-10-12) |

## C. Labeled assumptions (no public source; chosen and stated)
| Assumption | Value | Why |
|---|---|---|
| Campaign budget split | Equal within each channel ($900/$900 search, $600/$600 social) | So no campaign starts with an advantage |
| Paid sessions | 1 session per click | Keeps clicks and sessions reconcilable |
| Tag loss on paid sessions | 3%, which become "unassigned" with no campaign ID | Realistic mess; tests reconciliation |
| Paid visitor signs up without buying | 4% | Gives paid non-buyers |
| Non-paid first-touch mix | organic search 45%, direct 25%, referral 15%, organic social 15% | Typical small-site pattern; not sourced |
| Non-paid new customer buys in first session | 85% | **Volume setting**, tuned to reach the guide's ~1,200 orders |
| Chance a buyer orders again after each order | 55% | **Volume setting**, tuned to reach ~1,200 orders. Applies only to direct and organic returns, so it never favors a campaign |
| Repurchase gap | about 45 days (SD 15, minimum 14) | A 150 mL cleanser used twice daily lasts roughly 6 to 8 weeks; assumption |
| Email opt-in | 80% of customers | Assumption |
| Bounce rate | 1% | Assumption |
| Purchase after an email click | 8% of email sessions | Assumption |
| Funnel for non-buying sessions | 50% view a product, 18% of those add to cart, 40% of those reach checkout | Creates drop-off and abandoned carts |
| Items per order | 1 item 70%, 2 items 25%, 3 items 5%; each product equally likely | No product is favored |
| Refunds | 5% of orders, full refund 3 to 30 days later, only if inside the period | Assumption |
| Opens | Not simulated | Apple Mail Privacy Protection makes opens unreliable; the guide's email metric is click rate |
| Lifecycle emails | Welcome series (3 emails on days 0, 2, 5); cart recovery (24 hours after an abandoned cart, max 1 per 7 days); win-back (1st of Mar to Jun for buyers with 60+ days since their last order) | Matches email_style_plan.md |
| Prices | Oct 2026 prices applied to Jan to Jun 2026 | Limit: real prices may have differed |
| Tax, shipping, discounts | None | Keeps revenue definitions simple |

## D. What the run produced (seed 42)
| Table | Rows | Guide target |
|---|---|---|
| sim_customers | 1,000 (747 buyers, 253 non-buyers) | about 1,000 |
| sim_identity_map | 1,000 | |
| sim_campaigns | 4 | |
| sim_ad_daily | 724 (181 days x 4 campaigns) | |
| sim_sessions | 40,000 | 6,000 (changed by Option B) |
| sim_events | 69,710 | |
| sim_orders | 1,251 | about 1,200 |
| sim_email_deliveries | 3,126 | about 4,000. **Under target**: only 3 lifecycle flows are simulated and no newsletter was added to pad the count |

## E. Data QA at generation (all passed)
- Spend: search $1,800.00 and social $1,200.00 exactly. $0 on every day after Jan 30.
- Paid sessions (3,288) equal total clicks (3,288).
- Every order links to a session and a customer. The session's visitor maps to the same customer.
- There are no duplicate order IDs and no records after Jun 30.
- Purchase events (1,251) equal orders (1,251).
- No funnel step happens before the step it depends on.
- Net revenue $82,497 = gross $86,346 minus refunds $3,849. Revenue split by channel adds back to $82,497.
- No emails go to opted-out customers.

## F. Never done
- Simulated customers are never joined to public reviewers.
- Settings are never changed after seeing campaign results. The only tuning was the two volume settings (first-buy and repeat), which don't touch paid campaigns.
- Customer value is never called lifetime value.
