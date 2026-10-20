-- 10_campaign_performance.sql
-- Stage 6, Analysis 2 of 6: Campaign performance
-- Evidence layer: SIMULATED. Period: Jan 1 to Jun 30, 2026 (all paid spend falls on Jan 1 to 30).
-- Definitions: simulation/metric_definitions.md. Sums are divided; daily rates are never averaged.
-- Attribution: same-session last click. Paid sessions that lost their tag ('unassigned') are not credited to any campaign.

-- Q1. By campaign
SELECT c.campaign_id, c.campaign_name, c.channel, a.impressions, a.clicks, a.spend, ROUND(100.0 * a.clicks / a.impressions, 2) AS ctr_pct, ROUND(a.spend / a.clicks, 2) AS cpc, ROUND(a.spend * 1000.0 / a.impressions, 2) AS cpm, COALESCE(o.orders, 0) AS attributed_orders, ROUND(COALESCE(o.net, 0), 2) AS attributed_net_revenue, ROUND(a.spend / NULLIF(o.orders, 0), 2) AS cost_per_purchase, ROUND(COALESCE(o.net, 0) / a.spend, 2) AS roas FROM sim_campaigns c JOIN (SELECT campaign_id, SUM(impressions) AS impressions, SUM(clicks) AS clicks, ROUND(SUM(spend), 2) AS spend FROM sim_ad_daily GROUP BY campaign_id) a ON a.campaign_id = c.campaign_id LEFT JOIN (SELECT s.campaign_id, COUNT(*) AS orders, SUM(o.net_revenue) AS net FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id WHERE s.campaign_id IS NOT NULL GROUP BY s.campaign_id) o ON o.campaign_id = c.campaign_id ORDER BY c.campaign_id;

-- Q2. By channel (search vs social)
SELECT c.channel, SUM(a.impressions) AS impressions, SUM(a.clicks) AS clicks, ROUND(SUM(a.spend), 2) AS spend, ROUND(100.0 * SUM(a.clicks) / SUM(a.impressions), 2) AS ctr_pct, ROUND(SUM(a.spend) / SUM(a.clicks), 2) AS cpc, ROUND(SUM(a.spend) * 1000.0 / SUM(a.impressions), 2) AS cpm, (SELECT COUNT(*) FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id JOIN sim_campaigns c2 ON c2.campaign_id = s.campaign_id WHERE c2.channel = c.channel) AS attributed_orders, (SELECT ROUND(SUM(o.net_revenue), 2) FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id JOIN sim_campaigns c2 ON c2.campaign_id = s.campaign_id WHERE c2.channel = c.channel) AS attributed_net_revenue FROM sim_campaigns c JOIN sim_ad_daily a ON a.campaign_id = c.campaign_id GROUP BY c.channel;

-- Q3. Revenue reconciliation: campaign-attributed + everything else = total
SELECT CASE WHEN s.campaign_id IS NOT NULL THEN 'paid_attributed' WHEN s.channel = 'unassigned' THEN 'paid_lost_tag' ELSE 'non_paid' END AS bucket, COUNT(*) AS orders, ROUND(SUM(o.net_revenue), 2) AS net_revenue FROM sim_orders o JOIN sim_sessions s ON s.session_id = o.session_id GROUP BY 1 UNION ALL SELECT 'TOTAL', COUNT(*), ROUND(SUM(net_revenue), 2) FROM sim_orders;
