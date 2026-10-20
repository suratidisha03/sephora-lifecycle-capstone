-- 09_sim_data_qa.sql
-- Stage 6, Analysis 1 of 6: Data QA on simulated tables
-- Evidence layer: SIMULATED (Jan 1 to Jun 30, 2026). Run each query on its own in DB Browser (Execute SQL tab).

-- Q1. Row counts for all 8 tables
SELECT 'sim_customers' AS table_name, COUNT(*) AS row_count FROM sim_customers
UNION ALL SELECT 'sim_identity_map', COUNT(*) FROM sim_identity_map
UNION ALL SELECT 'sim_campaigns', COUNT(*) FROM sim_campaigns
UNION ALL SELECT 'sim_ad_daily', COUNT(*) FROM sim_ad_daily
UNION ALL SELECT 'sim_sessions', COUNT(*) FROM sim_sessions
UNION ALL SELECT 'sim_events', COUNT(*) FROM sim_events
UNION ALL SELECT 'sim_orders', COUNT(*) FROM sim_orders
UNION ALL SELECT 'sim_email_deliveries', COUNT(*) FROM sim_email_deliveries;
-- Expected: 1000, 1000, 4, 724, 40000, 69710, 1251, 3126

-- Q2. Reconcile spend: budgets vs daily ad data (must match)
SELECT c.campaign_id, c.budget, ROUND(SUM(a.spend), 2) AS daily_spend_total,
       ROUND(c.budget - SUM(a.spend), 2) AS difference
FROM sim_campaigns c JOIN sim_ad_daily a ON a.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.budget;
-- Expected: difference = 0 on all 4 rows

-- Q3. No spend outside Jan 1 to 30 (zero-spend days)
SELECT COUNT(*) AS rows_with_spend_after_jan30
FROM sim_ad_daily WHERE date > '2026-01-30' AND spend <> 0;
-- Expected: 0

-- Q4. Purchase events = orders
SELECT (SELECT COUNT(*) FROM sim_events WHERE event_name = 'purchase') AS purchase_events,
       (SELECT COUNT(*) FROM sim_orders) AS orders;
-- Expected: both 1251

-- Q5. Orphans: orders without a session or customer
SELECT
  (SELECT COUNT(*) FROM sim_orders o LEFT JOIN sim_sessions s ON s.session_id = o.session_id WHERE s.session_id IS NULL) AS orders_without_session,
  (SELECT COUNT(*) FROM sim_orders o LEFT JOIN sim_customers c ON c.customer_id = o.customer_id WHERE c.customer_id IS NULL) AS orders_without_customer;
-- Expected: 0, 0

-- Q6. Revenue reconciles: gross - refunds = net, and channels add up to the total
SELECT ROUND(SUM(gross_revenue), 2) AS gross, ROUND(SUM(refund_amount), 2) AS refunds,
       ROUND(SUM(net_revenue), 2) AS net,
       (SELECT ROUND(SUM(ch_net), 2) FROM (SELECT SUM(o.net_revenue) AS ch_net FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id GROUP BY s.channel)) AS net_by_channel_total
FROM sim_orders;
-- Expected: gross 86346, refunds 3849, net 82497, net_by_channel_total 82497

-- Q7. Realistic mess is present
SELECT
  (SELECT COUNT(*) FROM sim_sessions WHERE channel = 'unassigned') AS paid_sessions_lost_tag,
  (SELECT COUNT(*) FROM sim_orders WHERE refunded = 1) AS refunded_orders,
  (SELECT COUNT(*) FROM sim_customers WHERE customer_id NOT IN (SELECT customer_id FROM sim_orders)) AS non_buyers,
  (SELECT COUNT(DISTINCT date) FROM sim_ad_daily) AS days_in_ad_data;
-- Expected: lost tag about 3% of 3,288 paid clicks; refunds about 5% of orders; 253 non-buyers; 181 days

-- Q8. All checks from Q2 to Q7 in one row (same logic, one result)
SELECT (SELECT ROUND(SUM(budget),2) FROM sim_campaigns) AS budget_total, (SELECT ROUND(SUM(spend),2) FROM sim_ad_daily) AS ad_spend_total, (SELECT COUNT(*) FROM sim_ad_daily WHERE date > '2026-01-30' AND spend <> 0) AS spend_after_jan30, (SELECT COUNT(*) FROM sim_events WHERE event_name = 'purchase') AS purchase_events, (SELECT COUNT(*) FROM sim_orders) AS orders, (SELECT COUNT(*) FROM sim_orders o LEFT JOIN sim_sessions s ON s.session_id = o.session_id WHERE s.session_id IS NULL) AS orphan_orders, (SELECT ROUND(SUM(net_revenue),2) FROM sim_orders) AS net_revenue, (SELECT ROUND(SUM(o.net_revenue),2) FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id) AS net_revenue_via_sessions, (SELECT COUNT(*) FROM sim_sessions WHERE channel = 'unassigned') AS lost_tag_sessions, (SELECT COUNT(*) FROM sim_orders WHERE refunded = 1) AS refunded_orders, (SELECT COUNT(*) FROM sim_customers WHERE customer_id NOT IN (SELECT customer_id FROM sim_orders)) AS non_buyers;
-- Expected: 3000, 3000, 0, 1251, 1251, 0, 82497, 82497, 114, 50, 253
