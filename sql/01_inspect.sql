-- 01_inspect.sql
-- Purpose: check that every raw CSV loaded completely into capstone.db (Stage 2, checklist 2B/2C)
-- Input grain: public_raw_products = one row per product; public_raw_reviews_1..5 = one row per review
-- Output grain: one row per raw table, with its row count
-- Assumptions: tables were imported with header row on and trim off; review text may contain line breaks,
--              so compare against SQLite counts, not text-editor line counts
-- Reconcile: products should equal 8,494 and reviews_5 should equal 49,977 (counted from the files on 2026-10-08)

SELECT 'products'  AS tbl, COUNT(*) AS n FROM public_raw_products
UNION ALL SELECT 'reviews_1', COUNT(*) FROM public_raw_reviews_1
UNION ALL SELECT 'reviews_2', COUNT(*) FROM public_raw_reviews_2
UNION ALL SELECT 'reviews_3', COUNT(*) FROM public_raw_reviews_3
UNION ALL SELECT 'reviews_4', COUNT(*) FROM public_raw_reviews_4
UNION ALL SELECT 'reviews_5', COUNT(*) FROM public_raw_reviews_5;
