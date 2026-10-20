-- 02_column_check.sql
-- Purpose: confirm all 5 raw review tables have identical columns before combining them (checklist 2C, guide p.7)
-- Input grain: one row per column per table (from SQLite's pragma_table_info)
-- Output grain: one row per review table, with its column count and full column list in order
-- Assumptions: tables were imported with header row on; first column is the unnamed row number (field1)
-- Reconcile: all 5 rows should show 19 columns and the exact same column list

SELECT 'reviews_1' AS tbl, COUNT(*) AS n_cols, GROUP_CONCAT(name, ', ') AS columns FROM pragma_table_info('public_raw_reviews_1')
UNION ALL SELECT 'reviews_2', COUNT(*), GROUP_CONCAT(name, ', ') FROM pragma_table_info('public_raw_reviews_2')
UNION ALL SELECT 'reviews_3', COUNT(*), GROUP_CONCAT(name, ', ') FROM pragma_table_info('public_raw_reviews_3')
UNION ALL SELECT 'reviews_4', COUNT(*), GROUP_CONCAT(name, ', ') FROM pragma_table_info('public_raw_reviews_4')
UNION ALL SELECT 'reviews_5', COUNT(*), GROUP_CONCAT(name, ', ') FROM pragma_table_info('public_raw_reviews_5');
