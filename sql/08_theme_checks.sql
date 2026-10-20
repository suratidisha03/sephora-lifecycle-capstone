-- 08_theme_checks.sql
-- Purpose: check the 3 draft themes across ALL retained reviews (not just the 150-row coding sample), by year
-- Input grain: public_reviews = one row per retained review
-- Output grain: one row per year
-- Assumptions: keyword matching is a rough proxy; it over- and under-counts (e.g. "smell" in a positive review).
--              The hand-coded sample is the main evidence; these queries test whether a pattern holds more widely.
-- Reconcile (computed from the exported CSV on 2026-10-09):
--   Q1 First Aid Beauty low reviews mentioning "pill": 25 of 340 overall; 2016-2020 about 2% per year, 2021 12%, 2022 18%, 2023 28%
--   Q2 fresh cleanser reviews mentioning scent: 150 of 383 low (39%) and 1,066 of 2,695 high (40%)
--   Q3 Protini reviews mentioning price/value: 246 of 721 low (34%) and 682 of 2,219 high (31%)

-- Q1: First Aid Beauty Ultra Repair Cream, pilling mentions by year (low = 1-2 stars, high = 4-5)
SELECT SUBSTR(review_date, 1, 4) AS year,
       SUM(rating <= 2) AS low_reviews,
       SUM(rating <= 2 AND LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%pill%') AS low_mention_pilling,
       ROUND(100.0 * SUM(rating <= 2 AND LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%pill%') / SUM(rating <= 2), 1) AS pct_low,
       SUM(rating >= 4) AS high_reviews,
       SUM(rating >= 4 AND LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%pill%') AS high_mention_pilling
FROM public_reviews
WHERE product_id = 'P248407'
GROUP BY year ORDER BY year;

-- Q2: fresh Soy cleanser, scent mentions in low vs high reviews
SELECT CASE WHEN rating <= 2 THEN 'low 1-2' WHEN rating >= 4 THEN 'high 4-5' ELSE 'mid 3' END AS band,
       COUNT(*) AS reviews,
       SUM(LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%smell%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%scent%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%odor%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%fragrance%') AS mention_scent
FROM public_reviews
WHERE product_id = 'P7880'
GROUP BY band;

-- Q3: Drunk Elephant Protini, price/value mentions in low vs high reviews
SELECT CASE WHEN rating <= 2 THEN 'low 1-2' WHEN rating >= 4 THEN 'high 4-5' ELSE 'mid 3' END AS band,
       COUNT(*) AS reviews,
       SUM(LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%price%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%expensive%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%pricey%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%worth%'
        OR LOWER(COALESCE(review_title,'') || ' ' || COALESCE(review_text,'')) LIKE '%money%'
        OR COALESCE(review_title,'') || ' ' || COALESCE(review_text,'') LIKE '%$%') AS mention_price
FROM public_reviews
WHERE product_id = 'P427421'
GROUP BY band;
