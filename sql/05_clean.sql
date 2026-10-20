-- 05_clean.sql
-- Purpose: build the two clean Stage 2 tables (checklist 2G, guide p.8-9)
-- Input grain: public_raw_products = one row per product; all_raw_reviews = one row per raw review row
-- Output grain: public_products = one row per in-scope product (cleansers + moisturizers);
--               public_reviews  = one row per retained review for the 3 focal products
-- Assumptions:
--   * Scope = Skincare, tertiary_category 'Face Wash & Cleansers' or 'Moisturizers'
--   * Focal products = P7880 (fresh cleanser), P248407 (First Aid Beauty moisturizer), P427421 (Drunk Elephant moisturizer)
--   * Exact duplicates (same author_id + product_id + submission_time + review_text) keep one copy (QA-04)
--   * Cap = 3,333 most recent reviews per focal product; ties broken by source_file then field1 so reruns give the same rows
--   * IDs stay text; missing ratings stay NULL, never 0; raw tables are never changed
-- Reconcile: public_products = 603 rows (217 + 386); public_reviews <= 9,999 rows, 3,333 max per product

-- STEP 1: clean products table
DROP TABLE IF EXISTS public_products;
CREATE TABLE public_products AS
SELECT
  TRIM(product_id)                               AS product_id,
  product_name,
  brand_name,
  primary_category,
  secondary_category,
  tertiary_category,
  CAST(NULLIF(TRIM(price_usd), '') AS REAL)       AS price_usd,
  CAST(NULLIF(TRIM(rating), '') AS REAL)          AS product_level_rating,  -- site rating; never average with review rows
  CASE WHEN TRIM(product_id) IN ('P7880','P248407','P427421') THEN 1 ELSE 0 END AS is_focal
FROM public_raw_products
WHERE primary_category = 'Skincare'
  AND tertiary_category IN ('Face Wash & Cleansers', 'Moisturizers');

-- STEP 2: clean reviews table (dedup, then cap)
DROP TABLE IF EXISTS public_reviews;
CREATE TABLE public_reviews AS
WITH focal AS (
  SELECT * FROM all_raw_reviews
  WHERE TRIM(product_id) IN ('P7880','P248407','P427421')
),
deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY author_id, product_id, submission_time, review_text
                            ORDER BY source_file, field1) AS dup_rank
  FROM focal
),
capped AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY product_id
                            ORDER BY submission_time DESC, source_file, field1) AS recency_rank
  FROM deduped
  WHERE dup_rank = 1
)
SELECT
  TRIM(CAST(author_id AS TEXT))                  AS author_id,
  TRIM(product_id)                               AS product_id,
  CAST(NULLIF(TRIM(rating), '') AS REAL)          AS rating,
  is_recommended,
  DATE(submission_time)                          AS review_date,
  skin_type,
  skin_tone,
  REPLACE(review_title, char(13), ' ') AS review_title,   -- stray carriage returns broke the CSV export (QA-08)
  REPLACE(review_text,  char(13), ' ') AS review_text,
  source_file
FROM capped
WHERE recency_rank <= 3333;

-- FIX (2026-10-09, QA-08): run once on an already-built table instead of rebuilding
-- UPDATE public_reviews
-- SET review_text  = REPLACE(review_text,  char(13), ' '),
--     review_title = REPLACE(review_title, char(13), ' ');
