-- 06_qa.sql
-- Purpose: the guide's Stage 2 QA checks on the clean tables in one pass (checklist 2I, guide p.8-9)
-- Input grain: public_products = one row per product; public_reviews = one row per retained review
-- Output grain: one row, one column per check
-- Expected: dup_product_ids 0; unmatched_reviews 0; min_rating 1; max_rating 5; bad_dates 0;
--           reviews_per_product_max 3333; remaining_exact_dups 0; missing counts are reported, not failures

SELECT
  (SELECT COUNT(*) FROM (SELECT product_id FROM public_products GROUP BY product_id HAVING COUNT(*) > 1)) AS dup_product_ids,
  (SELECT COUNT(*) FROM public_reviews r LEFT JOIN public_products p ON r.product_id = p.product_id WHERE p.product_id IS NULL) AS unmatched_reviews,
  (SELECT MIN(rating) FROM public_reviews) AS min_rating,
  (SELECT MAX(rating) FROM public_reviews) AS max_rating,
  (SELECT MIN(review_date) FROM public_reviews) AS first_date,
  (SELECT MAX(review_date) FROM public_reviews) AS last_date,
  (SELECT SUM(review_date IS NULL) FROM public_reviews) AS bad_dates,
  (SELECT MAX(n) FROM (SELECT COUNT(*) AS n FROM public_reviews GROUP BY product_id)) AS reviews_per_product_max,
  (SELECT COUNT(*) FROM (SELECT 1 FROM public_reviews GROUP BY author_id, product_id, review_date, review_text HAVING COUNT(*) > 1)) AS remaining_exact_dups,
  (SELECT SUM(rating IS NULL) FROM public_reviews) AS missing_rating,
  (SELECT SUM(review_text IS NULL OR TRIM(review_text) = '') FROM public_reviews) AS missing_text,
  (SELECT SUM(skin_type IS NULL OR TRIM(skin_type) = '') FROM public_reviews) AS missing_skin_type,
  (SELECT SUM(is_recommended IS NULL OR TRIM(is_recommended) = '') FROM public_reviews) AS missing_recommended;
