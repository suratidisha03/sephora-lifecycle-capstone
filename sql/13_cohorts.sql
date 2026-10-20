-- 13_cohorts.sql
-- Stage 6, Analysis 5 of 6: Cohorts
-- Evidence layer: SIMULATED. Period: Jan 1 to Jun 30, 2026.
-- Cohort = month of a customer's FIRST purchase. Cell = % of that cohort who placed an order N months later.
-- Months that have not happened yet (after June 2026) stay BLANK (NULL), never 0. Month 0 is 100% by definition.
-- All dates are in 2026, so month offset = order month - cohort month.

WITH f AS (SELECT customer_id, MIN(order_ts) AS first_ts FROM sim_orders GROUP BY customer_id), fm AS (SELECT customer_id, CAST(strftime('%m', first_ts) AS INTEGER) AS cm FROM f), a AS (SELECT DISTINCT o.customer_id, fm.cm, CAST(strftime('%m', o.order_ts) AS INTEGER) - fm.cm AS k FROM sim_orders o JOIN fm ON fm.customer_id = o.customer_id), s AS (SELECT cm, COUNT(*) AS n FROM fm GROUP BY cm) SELECT '2026-' || printf('%02d', s.cm) AS cohort_month, s.n AS customers, CASE WHEN s.cm + 1 <= 6 THEN ROUND(100.0 * SUM(a.k = 1) / s.n, 1) END AS month_1_pct, CASE WHEN s.cm + 2 <= 6 THEN ROUND(100.0 * SUM(a.k = 2) / s.n, 1) END AS month_2_pct, CASE WHEN s.cm + 3 <= 6 THEN ROUND(100.0 * SUM(a.k = 3) / s.n, 1) END AS month_3_pct, CASE WHEN s.cm + 4 <= 6 THEN ROUND(100.0 * SUM(a.k = 4) / s.n, 1) END AS month_4_pct, CASE WHEN s.cm + 5 <= 6 THEN ROUND(100.0 * SUM(a.k = 5) / s.n, 1) END AS month_5_pct FROM s JOIN a ON a.cm = s.cm GROUP BY s.cm, s.n ORDER BY s.cm;
