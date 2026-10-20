-- 12_customer_behavior.sql
-- Stage 6, Analysis 4 of 6: Customer behavior
-- Evidence layer: SIMULATED. Period: Jan 1 to Jun 30, 2026. As-of date for recency: 2026-06-30.
-- Never called lifetime value. 90-day value only for customers whose first order is on or before 2026-04-01.

-- Q1. Summary: repeat rate, AOV, revenue per customer, 90-day value
WITH c AS (SELECT customer_id, COUNT(*) AS orders, SUM(net_revenue) AS net, MIN(order_ts) AS first_ts FROM sim_orders GROUP BY customer_id), d90 AS (SELECT c.customer_id, SUM(o.net_revenue) AS net_90 FROM c JOIN sim_orders o ON o.customer_id = c.customer_id WHERE c.first_ts <= '2026-04-01 23:59:59' AND o.order_ts < datetime(c.first_ts, '+90 days') GROUP BY c.customer_id) SELECT (SELECT COUNT(*) FROM sim_customers) AS all_customers, COUNT(*) AS purchasing_customers, SUM(orders) AS orders, ROUND(SUM(net), 2) AS net_revenue, ROUND(SUM(net) / SUM(orders), 2) AS aov, SUM(orders >= 2) AS repeat_customers, ROUND(100.0 * SUM(orders >= 2) / COUNT(*), 1) AS repeat_purchase_rate_pct, ROUND(SUM(net) / COUNT(*), 2) AS revenue_per_customer, (SELECT COUNT(*) FROM d90) AS customers_with_full_90d, (SELECT ROUND(SUM(net_90) / COUNT(*), 2) FROM d90) AS value_90d_per_customer FROM c;

-- Q2. RFM-style segments (rules written before running; as of 2026-06-30)
-- Champion: 3+ orders, last order within 30 days | Loyal: 2+ orders, last within 60 days | At risk: 2+ orders, last over 60 days ago
-- New: 1 order within 30 days | One-time, cooling: 1 order 31 to 60 days ago | One-time, lapsed: 1 order over 60 days ago
WITH c AS (SELECT customer_id, COUNT(*) AS f, SUM(net_revenue) AS m, CAST(julianday('2026-06-30 23:59:59') - julianday(MAX(order_ts)) AS INTEGER) AS r FROM sim_orders GROUP BY customer_id) SELECT CASE WHEN f >= 3 AND r <= 30 THEN '1 Champion' WHEN f >= 2 AND r <= 60 THEN '2 Loyal' WHEN f >= 2 THEN '3 At risk' WHEN r <= 30 THEN '4 New' WHEN r <= 60 THEN '5 One-time, cooling' ELSE '6 One-time, lapsed' END AS segment, COUNT(*) AS customers, ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM c), 1) AS pct_of_buyers, SUM(f) AS orders, ROUND(SUM(m), 2) AS net_revenue, ROUND(SUM(m) / COUNT(*), 2) AS revenue_per_customer, ROUND(AVG(r), 0) AS avg_days_since_last_order FROM c GROUP BY 1 ORDER BY 1;
