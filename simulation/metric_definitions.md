# Metric Definitions (LOCKED 2026-10-14, before any analysis)

Evidence layer: **Simulated**, Jan 1 to Jun 30, 2026. Source: the guide's metric table (Stage 6). Changing a definition after seeing results is not allowed; any change is logged in decisions.csv with its reason.

## Rules for every metric
- **Divide sums, never average daily rates.** For example, CTR = total clicks ÷ total impressions.
- Revenue means **net revenue**: gross minus refunds, using `sim_orders.net_revenue`.
- **Attribution:** an order belongs to the channel and campaign of the session it happened in (same-session, last click). Orders in sessions with no campaign ID count as unattributed.
- **Paid orders** are orders in `paid_search` or `paid_social` sessions that have a campaign ID. The 3% of paid clicks that lost their tag (`unassigned`) are **not** credited to any campaign.
- Every chart and table states its layer, period, filters and denominator.

| Metric | Formula | It is not |
|---|---|---|
| CTR | clicks ÷ impressions × 100 | purchase success |
| CPC | spend ÷ clicks | efficiency of sales |
| CPM | spend ÷ impressions × 1,000 | efficiency of sales |
| Cost per purchase | paid spend ÷ attributed orders | new-customer CAC |
| ROAS | attributed net revenue ÷ paid spend | profit or causal lift |
| AOV | net revenue ÷ orders | |
| Email click rate | delivered emails with a click ÷ delivered emails | open rate (opens not tracked) |
| Repeat purchase rate | customers with 2+ orders ÷ customers with 1+ order | cohort retention |
| Revenue per customer | net revenue ÷ purchasing customers | lifetime value |
| 90-day value | net revenue in the 90 days after first order, **only for customers whose first order is on or before Apr 1, 2026** (a full 90 days inside the data) | lifetime value |
| Visit-to-order rate | orders ÷ sessions | |

## Funnel definition
A session counts at a step only if the steps happen **in time order within that same session**: view_item, then add_to_cart, then begin_checkout, then purchase.

## Cohort definition
Customers are grouped by **first-purchase month**. A cohort month that hasn't happened yet stays **blank, never 0**.

## Reconciliation checks (must pass)
1. Campaign spend in `sim_campaigns` budgets = total spend in `sim_ad_daily` ($3,000).
2. Attributed + unattributed net revenue = total net revenue.
3. Purchase events = orders.
