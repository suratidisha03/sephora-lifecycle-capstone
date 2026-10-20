-- 07_insights.sql
-- Purpose: Stage 3 analysis steps 1-2 and the reproducible coding sample for step 3-4 (guide p.10)
-- Input grain: public_reviews = one row per retained review (3 focal products, 3,333 each)
-- Output grain: Step A/B = one row per product; Step C = one row per sampled review
-- Assumptions: low = rating 1-2, mid = 3, high = 4-5. Reviews describe this reviewer sample only, not all shoppers.
-- Reconcile: Step A n per product = 3,333. Step C = 150 rows (30 low + 20 high per product).

-- STEP A: rating distribution per product, full retained sample
SELECT product_id,
       COUNT(*) AS n,
       ROUND(AVG(rating), 2) AS mean_rating,
       SUM(rating = 1) AS r1, SUM(rating = 2) AS r2, SUM(rating = 3) AS r3, SUM(rating = 4) AS r4, SUM(rating = 5) AS r5,
       ROUND(100.0 * SUM(rating <= 2) / COUNT(*), 1) AS pct_low,
       ROUND(100.0 * SUM(rating >= 4) / COUNT(*), 1) AS pct_high,
       MIN(review_date) AS first_date, MAX(review_date) AS last_date
FROM public_reviews
GROUP BY product_id;

-- STEP B: same comparison inside the shared period (2019-08-23 to 2023-03-21),
-- because the products' review windows start in different years
SELECT product_id,
       COUNT(*) AS n,
       ROUND(AVG(rating), 2) AS mean_rating,
       ROUND(100.0 * SUM(rating <= 2) / COUNT(*), 1) AS pct_low,
       ROUND(100.0 * SUM(rating >= 4) / COUNT(*), 1) AS pct_high,
       COUNT(is_recommended) AS answered_recommend,
       ROUND(100.0 * SUM(is_recommended = 1) / COUNT(is_recommended), 1) AS pct_recommend_of_answered
FROM public_reviews
WHERE review_date >= '2019-08-23'
GROUP BY product_id;

-- STEP C: reproducible coding sample (changes the database: save with Cmd + S afterwards)
-- Rule: per product, the 30 most recent low (1-2) and 20 most recent high (4-5) reviews; ties broken by author_id
DROP TABLE IF EXISTS insight_coding_sample;
CREATE TABLE insight_coding_sample AS
SELECT product_id || '-' || band || '-' || printf('%02d', rk) AS sample_id, *
FROM (
  SELECT *, CASE WHEN rating <= 2 THEN 'L' ELSE 'H' END AS band,
         ROW_NUMBER() OVER (PARTITION BY product_id, CASE WHEN rating <= 2 THEN 'L' ELSE 'H' END
                            ORDER BY review_date DESC, author_id) AS rk
  FROM public_reviews
  WHERE rating <= 2 OR rating >= 4
)
WHERE (band = 'L' AND rk <= 30) OR (band = 'H' AND rk <= 20);

-- STEP C check. Expected: 150 rows, 50 per product
SELECT product_id, band, COUNT(*) AS n FROM insight_coding_sample GROUP BY product_id, band;
