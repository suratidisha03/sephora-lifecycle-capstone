# Source Log

Fill in each field from what the Kaggle page actually shows. Do not guess.

## Kaggle: Sephora Products and Skincare Reviews
| Field | Value |
|---|---|
| URL | https://www.kaggle.com/datasets/nadyinky/sephora-products-and-skincare-reviews |
| Creator | Nady Inky (nadyinky) |
| Access date | 2026-10-08 |
| Stated collection period | March 2023 ("collected via Python scraper in March 2023", Data Card); page shows "updated 3 years ago" |
| Stated contents | 8,000+ products and about 1 million user reviews from the Skincare category |
| License (exact text or link) | Creative Commons Attribution 4.0 International (CC BY 4.0), shown on the Kaggle page sidebar |
| Redistribution allowed? | Yes, with credit to the creator (Nady Inky, Kaggle) and a link to the license. Project choice: still share links, queries and aggregates only, not the raw files |
| Download method | Kaggle "Download" button, signed in, ZIP |
| ZIP filename and size | Sephora dataset.zip, 153.9 MB |
| Access issues | None |
| Usability score / update frequency | 10.00 / Never (per Kaggle sidebar) |

## File inventory
Row counts for the review files: fill in from SQLite after loading (review text contains line breaks, so do not count lines).

| File name | Size | Row count | Column headers |
|---|---|---|---|
| product_info.csv | 7.9 MB | 8,494 | 27 columns: product_id, product_name, brand_id, brand_name, loves_count, rating, reviews, size, variation_type, variation_value, variation_desc, ingredients, price_usd, value_price_usd, sale_price_usd, limited_edition, new, online_only, out_of_stock, sephora_exclusive, highlights, primary_category, secondary_category, tertiary_category, child_count, child_max_price, child_min_price |
| reviews_0-250.csv | 282.3 MB | 602,130 | Same 19 columns as below (confirm with PRAGMA) |
| reviews_250-500.csv | 100.3 MB | 206,725 | Same 19 columns (confirm) |
| reviews_500-750.csv | 56.3 MB | 116,262 | Same 19 columns (confirm) |
| reviews_750-1250.csv | 58.0 MB | 119,317 | Same 19 columns (confirm) |
| reviews_1250-end.csv | 24.2 MB | 49,977 | 19 columns: (unnamed index), author_id, rating, is_recommended, helpfulness, total_feedback_count, total_neg_feedback_count, total_pos_feedback_count, submission_time, review_text, review_title, skin_tone, eye_color, skin_type, hair_color, product_id, product_name, brand_name, price_usd |

## Notes from first inspection (2026-10-08)
- product_id is unique in product_info.csv (8,494 unique IDs). Join key to reviews: product_id (text, like P379064).
- Review files start with an unnamed index column. It is not a review ID. There is no review ID column.
- No incentivized or free-product flag column exists in the review files.
- submission_time is already in YYYY-MM-DD format.
- Reviews repeat product_name, brand_name and price_usd. Use the product table for these, not the review copy.
- Reviewer fields (skin_tone, eye_color, skin_type, hair_color) are self-reported.
- Raw ZIP kept untouched at: sources/ (move it there)
- Extracted CSVs belong in: data/raw/public/ (move them there)
