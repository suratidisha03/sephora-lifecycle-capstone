-- 03_overlap_check.sql
-- Purpose: combine the 5 raw review tables into one view (keeping which file each row came from),
--          then check for exact duplicate reviews inside or across files before any cleaning (checklist 2D, guide p.7)
-- Input grain: one row per review row in each raw file
-- Output grain: Step 1 = a view, one row per raw review row; Step 2 = one summary row
-- Assumptions: duplicate rule = same author_id + product_id + submission_time + review_text.
--              Same author with different text or date is a legitimate second review and is kept.
-- Reconcile: the view must have 1,094,411 rows (sum of the 5 tables in QA-01)

-- STEP 1: create the combined view (this changes the database: save afterwards with Cmd + S)
DROP VIEW IF EXISTS all_raw_reviews;
CREATE VIEW all_raw_reviews AS
SELECT *, 'reviews_0-250'    AS source_file FROM public_raw_reviews_1
UNION ALL SELECT *, 'reviews_250-500'  FROM public_raw_reviews_2
UNION ALL SELECT *, 'reviews_500-750'  FROM public_raw_reviews_3
UNION ALL SELECT *, 'reviews_750-1250' FROM public_raw_reviews_4
UNION ALL SELECT *, 'reviews_1250-end' FROM public_raw_reviews_5;

-- STEP 2: check the view row count. Expected: 1094411
SELECT COUNT(*) AS view_rows FROM all_raw_reviews;

-- STEP 3: count exact duplicates (read-only; may take up to a minute)
SELECT COUNT(*)                                   AS duplicate_groups,
       COALESCE(SUM(copies), 0)                   AS rows_involved,
       COALESCE(SUM(CASE WHEN files > 1 THEN 1 ELSE 0 END), 0) AS groups_across_files
FROM (
  SELECT author_id, product_id, submission_time, review_text,
         COUNT(*) AS copies, COUNT(DISTINCT source_file) AS files
  FROM all_raw_reviews
  GROUP BY author_id, product_id, submission_time, review_text
  HAVING COUNT(*) > 1
);
