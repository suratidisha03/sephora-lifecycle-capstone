-- 14_email.sql
-- Stage 6, Analysis 6 of 6: Email
-- Evidence layer: SIMULATED. Period: Jan 1 to Jun 30, 2026.
-- Email click rate = delivered emails with a click / delivered emails. Opens are not tracked (Apple Mail Privacy Protection).

-- Q1. Click rate by email type, plus total
SELECT email_type, COUNT(*) AS sent, SUM(delivered) AS delivered, SUM(delivered AND clicked) AS clicked, ROUND(100.0*SUM(delivered AND clicked)/SUM(delivered),2) AS click_rate_pct FROM sim_email_deliveries GROUP BY email_type UNION ALL SELECT 'ALL', COUNT(*), SUM(delivered), SUM(delivered AND clicked), ROUND(100.0*SUM(delivered AND clicked)/SUM(delivered),2) FROM sim_email_deliveries;
-- Expected: cart_recovery 262/261/4/1.53; welcome 2376/2355/49/2.08; win_back 488/481/11/2.29; ALL 3126/3097/64/2.07

-- Q2. Orders from email-click sessions (same-session attribution)
SELECT COUNT(*) AS email_sessions, (SELECT COUNT(*) FROM sim_orders o JOIN sim_sessions s USING(session_id) WHERE s.channel='email') AS email_orders, (SELECT SUM(net_revenue) FROM sim_orders o JOIN sim_sessions s USING(session_id) WHERE s.channel='email') AS email_net_revenue FROM sim_sessions WHERE channel='email';
-- Expected: 64, 8, 687
