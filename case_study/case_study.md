# Sephora: From Customer Insights to Lifecycle Strategy
**Independent capstone by Disha Surati | October 2026 | Simulated performance data**

> Independent capstone using Sephora as the subject of a speculative project. Public review data is historical. Campaign and customer performance are simulated. I built the linked analysis, dashboards and email prototypes; tracking and test-send evidence is labeled separately. Not affiliated with Sephora.

## Check it in 2 minutes: the 3 best links
| Link | Question it answers | My part | Status |
|---|---|---|---|
| [Looker Studio report](https://datastudio.google.com/reporting/7f7a22b2-0624-46f8-b9d5-4b598d8d3266) | Which campaigns and funnel steps turn clicks into orders? | Built the data sources, calculated fields and 3 pages | Interactive acquisition dashboard, simulated data |
| [Tableau Public dashboard](https://public.tableau.com/app/profile/disha.surati/viz/Sephora_Capstone_Cohorts_twbx/Cohortsdashboard) | Do first-time buyers come back, and when? | Built the cohort heatmap and value charts | Customer analytics dashboard, simulated data |
| [Live demo site](https://suratidisha03.github.io/routine-guide-demo/) | Does the tracking and email-to-cart path work? | Built the page, GA4/GTM events and cart link | Controlled demo; test traffic only |

Also: [SQL, QA log and data dictionary on GitHub](https://github.com/suratidisha03/sephora-lifecycle-capstone) (`qa/qa_log.csv`, 53 checks) and CRM scenario tests (`emails/scenario_test_log.csv`).

---

## 1. Problem
Skincare shoppers buy on trust: will it work for my skin, will it feel right, is it worth the price. The question I set myself:
**How could customer-review insights guide clearer product discovery, useful lifecycle emails and better acquisition-to-repeat-purchase decisions?**
This is a research question I proposed. It does not claim Sephora has a problem.

## 2. Scope
- **Products:** 3 skincare items (fresh Soy cleanser, First Aid Beauty Ultra Repair Cream, Drunk Elephant Protini).
- **Public data:** 9,999 Sephora reviews of those products (Kaggle, collected March 2023).
- **Simulated data:** Jan 1 to Jun 30, 2026, seed 42: 1,000 customers, 40,000 sessions, 1,251 orders, 3,126 emails, $3,000 of hypothetical January ad spend.
- **Test evidence:** my own demo site (GA4 and GTM) and Mailchimp test sends to my inbox.
- **Actual spend:** $0. No live ads, real customers or deployed automation.

The three layers never mix: reviewers are never joined to simulated customers, and reviews are never treated as purchases.

## 3. Method
1. **Cleaned the reviews in SQL** (SQLite) with logged checks for row counts, duplicates and joins (QA-01 to QA-08).
2. **Coded 150 recent reviews by theme**, checked 20 by hand (70% agreement; 6 codes corrected), then confirmed each theme across all 9,999 reviews in SQL (QA-09 to QA-15).
3. **Turned the themes into copy**: landing page, product pages, an SEO article, 7 emails and 2 ad hooks, each line traced to a review theme or a verified product fact.
4. **Built a demo site** and tracked 6 ecommerce events with GTM and GA4, verified in Tag Assistant and DebugView (QA-18 to QA-23).
5. **Simulated 8 linked tables** and locked 11 metric definitions before running any analysis. Wrote 6 SQL analyses: data QA, campaigns, funnel, customers and RFM, cohorts, email.
6. **Designed 3 lifecycle flows** (welcome, cart recovery, win-back) with entry, exit and suppression rules; tested the rules on 10 practice contacts in HubSpot Free; built 7 emails in Mailchimp and test-sent each one.
7. **Built 2 dashboards** (Looker Studio, Tableau Public) and checked every total against SQL.

## 4. Three findings

### Finding 1 (real public data): each product has one specific doubt, and one is growing
- **First Aid Beauty cream:** the share of low reviews mentioning "pill" went from about 2% a year (2016 to 2020) to 12% (2021), 18% (2022) and 28% (2023). Some reviewers say it pills only when layered over serums.
- **fresh Soy cleanser:** scent splits opinion. It appears in 39% of low and 40% of high reviews, and in 53% of 3-star reviews, so it decides the undecided.
- **Drunk Elephant Protini:** price comes up in 34% of low and 31% of high reviews. Even fans name it as the downside.
- *Limit:* reviewers self-select, and yearly counts are small (25 to 54 low reviews per year). This shows what reviewers said, not sales impact.

### Finding 2 (simulated): cheap clicks did not mean cheap sales
| Channel | CTR | CPC | Cost per purchase | ROAS |
|---|---|---|---|---|
| Social | 2.47% | $0.73 | $32.43 | 1.63 |
| Search | 1.67% | $1.10 | $29.03 | 2.40 |
- Social won on clicks; search won on sales (3.8% vs 2.2% of clicks became orders).
- *Limit:* this gap was built into the simulation inputs (published conversion rates), so it shows I can read the metrics correctly, not a discovery. Within each channel, the campaign gaps (29 vs 33 orders, 17 vs 20) are noise, so no budget shift is justified.

### Finding 3 (simulated): the biggest lifecycle target is one-time buyers who went quiet
- 42% of buyers bought twice or more, and they brought **65% of revenue** ($53,760 of $82,497).
- The largest segment is **"one-time, lapsed": 254 customers (34% of buyers)** with one order and no return in about 4 months. Another 125 repeat buyers are "at risk".
- Cohorts return most in month 2 (28% to 34%), then fade.
- *Limit:* the repeat rate and the month-2 peak come from simulation settings. Treat them as method practice, not benchmarks.

## 5. Decisions and tradeoffs
| Decision | Why | Tradeoff |
|---|---|---|
| Lead the cream page and day-2 email with a layering guide | Pilling is the growing complaint, and some of it happens only over other products | Admits a weakness on the page; it may lower clicks from people who hadn't worried about it |
| Describe the cleanser's scent and lather plainly, and offer the mini first | Scent decides 3-star buyers | Honest copy may put off some shoppers before they try it |
| Frame Protini by cost per week | Price is the shared objection | Still a high price; framing can't fix value for everyone |
| Judge paid campaigns on cost per purchase, not CPC | Cheap clicks cost more per sale | Needs enough orders per campaign to decide; this data had 17 to 33 |
| Point the win-back flow at the 254 lapsed and 125 at-risk buyers | They are the largest and the cheapest audiences to win back | Risk of over-mailing; capped at 1 email a day and 3 a week, and win-back can restart only 60 days after the flow ends |
| Rebuild the bag from the cart email link | The first test send linked to an empty bag (QA-33) | One more feature to maintain on the demo site |

## 6. Validation
- **53 logged QA checks** (`qa/qa_log.csv`): data loads, joins, duplicates, metric reconciliation, tracking, email rendering and dashboards.
- **Money reconciles:** spend $3,000 = $3,000; $6,267 attributed + $228 lost-tag + $76,002 non-paid = $82,497 total.
- **Funnel in time order:** a step counts only after the previous one in the same session; all 1,251 purchases passed.
- **Cohorts:** months not yet reached are blank, never 0.
- **Dashboards:** every total matches SQL; both links open signed out (QA-49, QA-53).
- **Errors I caught and fixed:**
  - The first cart email linked to an empty bag. I rebuilt the bag from the link and retested it live (QA-33, QA-40).
  - Future cohort months showed as shaded cells in Tableau. I rebuilt the chart from a file without them (QA-44, QA-51).
  - The Mailchimp importer merged lines. I switched to the code editor (QA-42).
- **AI use** is logged in `ai_log/ai_log.md`. AI-coded reviews were checked by hand before use.

## 7. Limitations
- **Performance data is simulated.** It proves I can calculate and explain the metrics, not that these campaigns or emails would work.
- **Several patterns were built into the inputs** (search vs social conversion, the repeat rate, the month-2 peak). I say so wherever they appear.
- **The reviews are a self-selected 2016 to 2023 sample.** They don't show sales, returns or skin outcomes, and they don't represent all Sephora shoppers.
- **Lifecycle flows are prototypes.** Mailchimp Free has no multi-step automation, so the emails were built and test-sent, not run as live flows.
- **Tracking was tested on my own demo traffic only.** 114 simulated paid sessions lost their campaign tag, which slightly understates campaign ROAS.
- **Next tests:** A/B the layering guide on the cream page (outcome: add to cart), the scent copy (outcome: mini selection), and cost-per-week framing in the welcome email (outcome: click rate).
