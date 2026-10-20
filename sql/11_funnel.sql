-- 11_funnel.sql
-- Stage 6, Analysis 3 of 6: Funnel
-- Evidence layer: SIMULATED. Period: Jan 1 to Jun 30, 2026. Denominator: all 40,000 sessions.
-- Rule (guide): a session counts at a step only if the steps happen in time order within the same session:
-- view_item, then add_to_cart, then begin_checkout, then purchase.

-- Q1. Overall funnel with step-to-step rates
WITH f AS (SELECT session_id, MIN(CASE WHEN event_name = 'view_item' THEN event_ts END) AS v, MIN(CASE WHEN event_name = 'add_to_cart' THEN event_ts END) AS a, MIN(CASE WHEN event_name = 'begin_checkout' THEN event_ts END) AS c, MIN(CASE WHEN event_name = 'purchase' THEN event_ts END) AS p FROM sim_events GROUP BY session_id), s AS (SELECT COUNT(*) AS sessions, SUM(v IS NOT NULL) AS viewed, SUM(v IS NOT NULL AND a > v) AS carted, SUM(v IS NOT NULL AND a > v AND c > a) AS checked_out, SUM(v IS NOT NULL AND a > v AND c > a AND p > c) AS purchased FROM f) SELECT sessions, viewed, ROUND(100.0 * viewed / sessions, 1) AS view_rate_pct, carted, ROUND(100.0 * carted / viewed, 1) AS cart_of_viewed_pct, checked_out, ROUND(100.0 * checked_out / carted, 1) AS checkout_of_carted_pct, purchased, ROUND(100.0 * purchased / checked_out, 1) AS purchase_of_checkout_pct, ROUND(100.0 * purchased / sessions, 2) AS session_to_order_pct FROM s;

-- Q2. Funnel by channel
WITH f AS (SELECT session_id, MIN(CASE WHEN event_name = 'view_item' THEN event_ts END) AS v, MIN(CASE WHEN event_name = 'add_to_cart' THEN event_ts END) AS a, MIN(CASE WHEN event_name = 'begin_checkout' THEN event_ts END) AS c, MIN(CASE WHEN event_name = 'purchase' THEN event_ts END) AS p FROM sim_events GROUP BY session_id) SELECT s.channel, COUNT(*) AS sessions, SUM(f.v IS NOT NULL) AS viewed, SUM(f.v IS NOT NULL AND f.a > f.v) AS carted, SUM(f.v IS NOT NULL AND f.a > f.v AND f.c > f.a) AS checked_out, SUM(f.v IS NOT NULL AND f.a > f.v AND f.c > f.a AND f.p > f.c) AS purchased, ROUND(100.0 * SUM(f.v IS NOT NULL AND f.a > f.v AND f.c > f.a AND f.p > f.c) / COUNT(*), 2) AS session_to_order_pct FROM f JOIN sim_sessions s ON s.session_id = f.session_id GROUP BY s.channel ORDER BY sessions DESC;
