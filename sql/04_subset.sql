-- 04_subset.sql
-- Purpose: find the real category values and pick the cleanser and moisturizer products (checklist 2F, guide p.7-8)
-- Input grain: public_raw_products = one row per product; all_raw_reviews = one row per raw review row
-- Output grain: Step 1 = one row per skincare category combination; Step 2 = one row per candidate product
-- Assumptions: scope = tertiary_category 'Face Wash & Cleansers' and 'Moisturizers' (decided 2026-10-08 from product_info.csv)
-- Reconcile: Step 1 should show 217 'Face Wash & Cleansers' and 386 'Moisturizers' products under Skincare

-- STEP 1: category values inside Skincare
SELECT secondary_category, tertiary_category, COUNT(*) AS products
FROM public_raw_products
WHERE primary_category = 'Skincare'
GROUP BY secondary_category, tertiary_category
ORDER BY secondary_category, tertiary_category;
