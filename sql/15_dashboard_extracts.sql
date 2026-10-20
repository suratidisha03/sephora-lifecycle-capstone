-- 15_dashboard_extracts.sql
-- Stage 8: tables that feed Looker Studio and Tableau Public. Evidence layer: SIMULATED, Jan 1 to Jun 30, 2026.
-- Same logic as sql/10 to 14 (same-session last click; time-ordered funnel; first-purchase-month cohorts; blank future months).
-- Each extract is exported to dashboards/data/ as CSV. Totals are checked against Stage 6 in qa_log (QA-43+).

-- X1. dash_acquisition_daily: one row per date x campaign. Orders/revenue dated by order date, credited to the session's campaign.
DROP TABLE IF EXISTS dash_acquisition_daily;
CREATE TABLE dash_acquisition_daily AS
WITH att AS (SELECT date(o.order_ts) AS d, s.campaign_id, COUNT(*) AS orders, SUM(o.net_revenue) AS net
             FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id
             WHERE s.campaign_id IS NOT NULL GROUP BY 1, 2),
keys AS (SELECT date AS d, campaign_id FROM sim_ad_daily UNION SELECT d, campaign_id FROM att)
SELECT k.d AS date, k.campaign_id, c.campaign_name, c.channel,
       COALESCE(a.impressions, 0) AS impressions, COALESCE(a.clicks, 0) AS clicks, ROUND(COALESCE(a.spend, 0), 2) AS spend,
       COALESCE(t.orders, 0) AS attributed_orders, ROUND(COALESCE(t.net, 0), 2) AS attributed_net_revenue,
       'Simulated (seed 42)' AS evidence_layer
FROM keys k JOIN sim_campaigns c ON c.campaign_id = k.campaign_id
LEFT JOIN sim_ad_daily a ON a.date = k.d AND a.campaign_id = k.campaign_id
LEFT JOIN att t ON t.d = k.d AND t.campaign_id = k.campaign_id;

-- X2. dash_funnel_daily: one row per session date x channel x tag status, with time-ordered funnel steps.
DROP TABLE IF EXISTS dash_funnel_daily;
CREATE TABLE dash_funnel_daily AS
WITH f AS (SELECT session_id, MIN(CASE WHEN event_name='view_item' THEN event_ts END) AS v, MIN(CASE WHEN event_name='add_to_cart' THEN event_ts END) AS a,
                  MIN(CASE WHEN event_name='begin_checkout' THEN event_ts END) AS c, MIN(CASE WHEN event_name='purchase' THEN event_ts END) AS p
           FROM sim_events GROUP BY session_id)
SELECT date(s.session_start) AS date, s.channel,
       CASE WHEN s.channel = 'unassigned' THEN 'Lost tag (paid click, no campaign ID)' WHEN s.campaign_id IS NOT NULL THEN 'Tagged campaign' ELSE 'Non-paid' END AS tag_status,
       COUNT(*) AS sessions, SUM(f.v IS NOT NULL) AS viewed, SUM(f.v IS NOT NULL AND f.a > f.v) AS carted,
       SUM(f.v IS NOT NULL AND f.a > f.v AND f.c > f.a) AS checked_out, SUM(f.v IS NOT NULL AND f.a > f.v AND f.c > f.a AND f.p > f.c) AS purchased,
       'Simulated (seed 42)' AS evidence_layer
FROM sim_sessions s LEFT JOIN f ON f.session_id = s.session_id GROUP BY 1, 2, 3;

-- X3. dash_customers: one row per purchasing customer (as of 2026-06-30).
DROP TABLE IF EXISTS dash_customers;
CREATE TABLE dash_customers AS
WITH c AS (SELECT customer_id, COUNT(*) AS orders, SUM(net_revenue) AS net, MIN(order_ts) AS first_ts, MAX(order_ts) AS last_ts,
                  CAST(julianday('2026-06-30 23:59:59') - julianday(MAX(order_ts)) AS INTEGER) AS r FROM sim_orders GROUP BY customer_id),
d90 AS (SELECT c.customer_id, SUM(o.net_revenue) AS net_90 FROM c JOIN sim_orders o ON o.customer_id = c.customer_id
        WHERE c.first_ts <= '2026-04-01 23:59:59' AND o.order_ts < datetime(c.first_ts, '+90 days') GROUP BY c.customer_id)
SELECT c.customer_id, cu.acquisition_channel, strftime('%Y-%m', c.first_ts) AS cohort_month, c.orders,
       CASE WHEN c.orders >= 3 THEN '3+ orders' WHEN c.orders = 2 THEN '2 orders' ELSE '1 order' END AS order_bucket,
       (c.orders >= 2) AS is_repeat, ROUND(c.net, 2) AS net_revenue, c.r AS days_since_last_order,
       CASE WHEN c.orders >= 3 AND c.r <= 30 THEN '1 Champion' WHEN c.orders >= 2 AND c.r <= 60 THEN '2 Loyal' WHEN c.orders >= 2 THEN '3 At risk'
            WHEN c.r <= 30 THEN '4 New' WHEN c.r <= 60 THEN '5 One-time, cooling' ELSE '6 One-time, lapsed' END AS rfm_segment,
       (c.first_ts <= '2026-04-01 23:59:59') AS has_full_90d, CASE WHEN c.first_ts <= '2026-04-01 23:59:59' THEN ROUND(d.net_90, 2) END AS net_revenue_90d,
       'Simulated (seed 42)' AS evidence_layer
FROM c JOIN sim_customers cu ON cu.customer_id = c.customer_id LEFT JOIN d90 d ON d.customer_id = c.customer_id;

-- X4. dash_email: one row per send date x email type x step.
DROP TABLE IF EXISTS dash_email;
CREATE TABLE dash_email AS
SELECT date(send_ts) AS send_date, email_type, step, COUNT(*) AS sent, SUM(delivered) AS delivered, SUM(delivered AND clicked) AS clicked_delivered,
       'Simulated (seed 42)' AS evidence_layer
FROM sim_email_deliveries GROUP BY 1, 2, 3;

-- X5. tableau_cohort_long: one row per cohort x month offset 0 to 5. pct is NULL (blank) for months not reached by 2026-06.
DROP TABLE IF EXISTS tableau_cohort_long;
CREATE TABLE tableau_cohort_long AS
WITH f AS (SELECT customer_id, MIN(order_ts) AS first_ts FROM sim_orders GROUP BY customer_id),
fm AS (SELECT customer_id, CAST(strftime('%m', first_ts) AS INTEGER) AS cm FROM f),
a AS (SELECT DISTINCT o.customer_id, fm.cm, CAST(strftime('%m', o.order_ts) AS INTEGER) - fm.cm AS k FROM sim_orders o JOIN fm ON fm.customer_id = o.customer_id),
s AS (SELECT cm, COUNT(*) AS n FROM fm GROUP BY cm),
k AS (SELECT 0 AS k UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5)
SELECT '2026-' || printf('%02d', s.cm) AS cohort_month, k.k AS months_since_first_order, s.n AS cohort_customers,
       CASE WHEN s.cm + k.k <= 6 THEN (SELECT COUNT(*) FROM a WHERE a.cm = s.cm AND a.k = k.k) END AS customers_ordering,
       CASE WHEN s.cm + k.k <= 6 THEN ROUND(100.0 * (SELECT COUNT(*) FROM a WHERE a.cm = s.cm AND a.k = k.k) / s.n, 1) END AS pct_ordering,
       'Simulated (seed 42)' AS evidence_layer
FROM s CROSS JOIN k ORDER BY s.cm, k.k;
