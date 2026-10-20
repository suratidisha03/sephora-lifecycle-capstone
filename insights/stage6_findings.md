# Stage 6 Findings (SIMULATED data, Jan 1 to Jun 30, 2026)

Every number here comes from generated data (seed 42). Nothing describes real Sephora results.
Definitions: simulation/metric_definitions.md.

## Analysis 1: Data QA (sql/09_sim_data_qa.sql)
All checks passed (QA-25). Spend $3,000 = $3,000; $0 after Jan 30; 1,251 purchase events = 1,251 orders; 0 orphan orders; net revenue $82,497 reconciles across channels.

## Analysis 2: Campaign performance (sql/10_campaign_performance.sql)
Paid spend $3,000 on Jan 1 to 30. Attribution is same-session last click. Denominators: clicks for CTR, attributed orders for cost per purchase, paid spend for ROAS.

| Campaign | Spend | Clicks | CTR | CPC | Orders | Cost/purchase | ROAS |
|---|---|---|---|---|---|---|---|
| C01 Search: fresh cleanser | $900 | 803 | 1.64% | $1.12 | 29 | $31.03 | 2.11 |
| C02 Search: FAB cream pilling tips | $900 | 830 | 1.71% | $1.08 | 33 | $27.27 | 2.69 |
| C03 Social: Protini value | $600 | 828 | 2.51% | $0.72 | 17 | $35.29 | 1.44 |
| C04 Social: two-step routine | $600 | 827 | 2.43% | $0.73 | 20 | $30.00 | 1.81 (exactly 1.815; DB Browser rounds down) |
| **Search total** | $1,800 | 1,633 | 1.67% | $1.10 | 62 | $29.03 | 2.40 |
| **Social total** | $1,200 | 1,655 | 2.47% | $0.73 | 37 | $32.43 | 1.63 |

Reconciliation: paid-attributed $6,267 (99 orders) + lost-tag paid $228 (3 orders) + non-paid $76,002 (1,149 orders) = $82,497 (1,251 orders).

### How to read it (and what not to claim)
1. **Social wins on clicks and search wins on sales.** Social has a higher CTR and lower CPC; search turns clicks into orders more often. A cheap click is not a cheap sale.
2. **Search vs social is a real gap in this data.** Click-to-order is 3.8% for search vs 2.2% for social (62/1,633 vs 37/1,655; two-proportion z of about 2.6). **But it was built in**: the inputs used different published conversion rates (4.33% vs 1.79%). So the analysis confirms the inputs; it is not a discovery.
3. **No campaign "won" inside a channel.** C01 vs C02 is 29 vs 33 orders, and C03 vs C04 is 17 vs 20. Budgets and rates were identical, so these gaps are random noise. With 17 to 33 orders per campaign, no budget shift is justified.
4. **ROAS is not profit.** ROAS 2.40 means $2.40 of net revenue per $1 of ads, before product cost, shipping and returns handling.
5. **Paid drove 8% of revenue.** $6,267 of $82,497. Most revenue came from non-paid visits and repeat buyers, which ads did not touch in this simulation.

## Analysis 3: Funnel (sql/11_funnel.sql)
Denominator: all 40,000 sessions. A step counts only if it happens after the previous step in the same session.

| Step | Sessions | Rate of previous step |
|---|---|---|
| All sessions | 40,000 | |
| Viewed a product | 20,752 | 51.9% of sessions |
| Added to cart | 4,810 | 23.2% of viewers |
| Reached checkout | 2,643 | 54.9% of carts |
| Purchased | 1,251 | 47.3% of checkouts |
| **Session to order** | | **3.13%** |

### How to read it
1. **The biggest losses are early.** About half of visits never open a product, and 77% of people who view a product don't add it to the cart. That is where the Stage 3 doubts (scent, pilling, price) would bite, and where the Stage 4 copy is aimed.
2. **Honest limit:** the drop-off rates come from the simulation settings (sim_assumptions.md, section C). This analysis shows the **method** (time-ordered, same-session steps), not real shopper behavior. Real drop-off would need the live GA4 data, which has no real traffic.
3. All 1,251 purchases passed the time-order check, so no out-of-order sessions were counted.

## Analysis 4: Customer behavior (sql/12_customer_behavior.sql)
Denominator: 747 purchasing customers (of 1,000). As of 2026-06-30.

| Metric | Value |
|---|---|
| Purchasing customers | 747 of 1,000 (253 never bought) |
| Orders / net revenue | 1,251 / $82,497 |
| AOV | $65.94 |
| Repeat purchase rate | 42.3% (316 of 747 bought 2+ times) |
| Revenue per customer | $110.44 (not lifetime value) |
| 90-day value | $109.01, for the 446 customers whose first order was on or before Apr 1 |

### RFM segments (rules written before running)
| Segment | Customers | % of buyers | Net revenue | Revenue per customer | Avg days since last order |
|---|---|---|---|---|---|
| Champion (3+ orders, last 30 days) | 65 | 8.7% | $16,173 | $248.82 | 13 |
| Loyal (2+ orders, last 60 days) | 126 | 16.9% | $19,767 | $156.88 | 34 |
| At risk (2+ orders, over 60 days) | 125 | 16.7% | $17,820 | $142.56 | 102 |
| New (1 order, last 30 days) | 116 | 15.5% | $8,016 | $69.10 | 15 |
| One-time, cooling (1 order, 31 to 60 days) | 61 | 8.2% | $4,065 | $66.64 | 44 |
| One-time, lapsed (1 order, over 60 days) | 254 | 34.0% | $16,656 | $65.57 | 130 |
Checks: segments add to 747 customers, 1,251 orders and $82,497.

### How to read it
1. **The 42% repeat rate is driven by a setting.** The 55% per-order repeat chance was tuned to reach the guide's order volume. Don't present 42% as a benchmark.
2. **Repeat buyers are a minority but carry most revenue.** Champion + Loyal + At risk = 316 customers (42%) and $53,760 (65% of revenue).
3. **The biggest lifecycle target is "One-time, lapsed"**: 254 customers (34% of buyers) who bought once and haven't returned in about 4 months. This is the audience the win-back email is for.
4. **"At risk" (125)** are proven repeat buyers going quiet. They're cheaper to bring back than finding new customers, and they are the second win-back audience.
5. 90-day value ($109) is close to revenue per customer ($110) because most repeat orders happen within about 90 days, given the 45-day repurchase gap in the settings.

## Analysis 5: Cohorts (sql/13_cohorts.sql)
Cohort = month of first purchase. Each cell = % of the cohort who ordered N months later. NULL = month not reached yet (never shown as 0).

| Cohort | Customers | m1 | m2 | m3 | m4 | m5 |
|---|---|---|---|---|---|---|
| 2026-01 | 222 | 23.9 | 29.3 | 18.0 | 13.1 | 10.4 |
| 2026-02 | 109 | 17.4 | 33.9 | 22.0 | 14.7 | blank |
| 2026-03 | 110 | 29.1 | 28.2 | 19.1 | blank | blank |
| 2026-04 | 103 | 26.2 | 29.1 | blank | blank | blank |
| 2026-05 | 86 | 25.6 | blank | blank | blank | blank |
| 2026-06 | 117 | blank | blank | blank | blank | blank |

### How to read it
1. **January is twice the size of other cohorts** (222 vs about 100). That's the $3,000 of January ads bringing in extra first-time buyers. Other months have no paid spend.
2. **Return orders peak in month 2** (about 28 to 34%) and fade after that. That follows the 45-day repurchase gap in the settings, so it's a built-in pattern, not a discovery.
3. **The January paid cohort returns at a similar rate to non-paid cohorts.** Paid customers weren't set up to behave differently, so this is expected.
4. Method check: blanks are correct (QA-26). A 0 would wrongly say "nobody came back" for months that hadn't happened yet.

## Analysis 6: Email (sql/14_email.sql)
Click rate = delivered emails with a click ÷ delivered emails. Opens are not tracked.

| Email type | Sent | Delivered | Clicked | Click rate |
|---|---|---|---|---|
| Cart recovery | 262 | 261 | 4 | 1.53% |
| Welcome | 2,376 | 2,355 | 49 | 2.08% |
| Win-back | 488 | 481 | 11 | 2.29% |
| **All** | 3,126 | 3,097 | 64 | **2.07%** |

Email-click sessions: 64 sessions, 8 orders, $687 net revenue (0.8% of total).

### How to read it
1. **The gaps between email types are noise.** Every type was simulated at the same 2% click chance, and the counts are tiny (4 and 11 clicks). Don't rank the flows from this data.
2. **2.07% overall sits between Mailchimp's benchmarks** (1.74% e-commerce, 2.62% all users, Dec 2023), because that's where the input was set. It shows the metric is calculated correctly, not that the emails would perform that way.
3. **What the email data can do:** test the method (right denominator, no opens) and size the audiences for Stage 7: 254 one-time lapsed and 125 at-risk buyers for win-back (Analysis 4).

## Stage 6 gate check (guide: data reconciles, every metric runs, definitions written)
| Requirement | Status | Evidence |
|---|---|---|
| 8 linked tables, seed 42 | Done | simulation/generate_sim_data.py; data/sim/ |
| Realistic mess (refunds, non-buyers, missing campaign IDs, zero-spend days) | Done | 50 refunds; 253 non-buyers; 114 lost tags; 151 zero-spend days |
| No forced winning campaign | Done | Equal budgets and rates within each channel |
| Metric definitions locked before analysis | Done | simulation/metric_definitions.md |
| 6 SQL analyses | Done | sql/09 to 14 |
| Funnel in time order within one session | Done | sql/11_funnel.sql |
| Cohorts by first-purchase month, future months blank | Done | sql/13_cohorts.sql |
| Customer value: observed revenue, 90-day value (full 90 days only), RFM; never "lifetime value" | Done | sql/12_customer_behavior.sql |
| Reconcile spend and revenue | Done | Spend $3,000 = $3,000; attributed $6,267 + lost-tag $228 + non-paid $76,002 = $82,497 |
| Every metric in the table runs | Done | CTR, CPC, CPM, cost per purchase, ROAS, AOV, email click rate, repeat rate, revenue per customer |
**Gate: PASSED (2026-10-14).**
